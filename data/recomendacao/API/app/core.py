import pandas as pd
import polars as pl
from numpy import unique, quantile
from random import sample 
from collections import defaultdict
from mlxtend.preprocessing import TransactionEncoder
from mlxtend.frequent_patterns import apriori, association_rules

from timy import timer
from utils.native import flatten_list
from utils.dataframe import get_unique_elements, \
    listify_items
from utils.file import create_folder, extend_filename
from utils.constants import NEIGHBORS_COUNT_DEFAULT, \
    MIN_SET_SIZE_CONFIDENCE


    
def get_items_sample(
    df_: pd.DataFrame,
    column: str,
    sample_count: int
):
    item_ids = get_unique_elements(df_, column)
    return list(sample(item_ids, sample_count))

def get_sets_count_per_items_dict(
    df_: pd.DataFrame,
    sets_column: str,
    items_column: str
):
    result = df_.groupby(items_column)[sets_column].count().reset_index()
    result_dict = result.set_index(items_column)[sets_column].to_dict()

    return result_dict

def get_sets_count_per_items(
    df_: pd.DataFrame,
    sets_column: str,
    items_column: str
):
    # Group by items_column and count sets_column, then reset the index
    counts = df_.groupby(items_column)[sets_column].count().reset_index()
    
    # Rename the count column
    counts = counts.rename(columns={sets_column: 'count'})

    # Sort the DataFrame by the count column in descending order
    counts = counts.sort_values(by='count', ascending=False)
    
    return counts

def get_sets_to_items_dict(
    df_: pd.DataFrame,
    sets_column: str,
    items_column: str
):    
    # Group by 'order_id' and aggregate 'product_id' into a list
    result = listify_items(df_, sets_column, items_column)

    # Convert to list of lists
    products_per_order = result[['items_list']].values.tolist()
    orders_id = list(result[sets_column])
    
    return {
        order_id: list(unique(lst[0]))
        for order_id, lst in zip(orders_id, products_per_order) 
    }

def get_items_support(
    sets_count_dict: dict, 
    sets_total: int
):
    return {
        item_id: sets_count/sets_total
        for item_id, sets_count in sets_count_dict.items()
    }

# Confidence(A→B) = Probability(A & B) / Support(A)
def get_items_confidence(
    item_to_neighbors_dict: dict,
    items_support_dict: dict,
    sets_total: int
):    
    
    neighbors_support_dict = {
        item_id: {
            neighbor_id: neighbor_count/sets_total
            for neighbor_id, neighbor_count in neighbors.items()
        }
        for item_id, neighbors in item_to_neighbors_dict.items()
    }
    
    return {
        item_id: {
            neighbor_id: neighbor_support/items_support_dict[item_id]
            for neighbor_id, neighbor_support in neighbors.items()
        }
        for item_id, neighbors in neighbors_support_dict.items()
    }

# Lift(A→B) = Confidence(A→B) / Support(B)
def get_items_lift(
    items_supports_dict: dict, 
    confidences_dict: dict
):
    return {
        item_id: {
            neighbor_id: neighbor_confidence/items_supports_dict[neighbor_id]
            for neighbor_id, neighbor_confidence in this_item_confidences.items()
        }
        for item_id, this_item_confidences in confidences_dict.items()
    }

def get_association_metrics(
    df_: pd.DataFrame,
    neighbors: dict,
    sets_column: str, 
    items_column: str
):
    sets_count_dict = get_sets_count_per_items_dict(df_, sets_column, items_column)
    sets_total = len(get_unique_elements(df_, sets_column))
    
    items_support = get_items_support(sets_count_dict, sets_total)
    items_confidence = get_items_confidence(neighbors, items_support, sets_total)
    items_lift = get_items_lift(items_support, items_confidence)

    # TODO: 
    # Leverage: P(A and B) - P(A) * P(B)
    # Conviction: P(A and B) / (P(A) * P(B))
    # zhang_metric: Zhang(A -> B) = P(B_given_A) - P(B)

    return {
        item_id: {
            'support': item_support,
            'neighbors': {
                neighbor_id: {
                    'confidence': neighbor_confidence,
                    'lift': items_lift[item_id][neighbor_id]
                } 
                for neighbor_id, neighbor_confidence in items_confidence[item_id].items()
            }
        }
        for item_id, item_support in items_support.items()
    }

def get_items_neighbors_count(
    df_:pd.DataFrame,
    sets_column: str,
    items_column: str
):
    item_ids = get_unique_elements(df_, items_column)
    sets_list = listify_items(df_, sets_column, items_column)

    item_neighbors = {
        item_id: defaultdict(int) for item_id in item_ids
    }
    
    for item_id in item_ids:
        set_list_with_item_id = [
            set_list 
            for set_list in sets_list
            if item_id in set_list
        ]

        for set_list in set_list_with_item_id:
                set_list_without_item_id = list(set(set_list)-set([item_id]))
    
                for friend_id in set_list_without_item_id:
                    friend_i_value = item_neighbors[item_id][friend_id]
                    item_neighbors[item_id][friend_id] = friend_i_value + 1
            

    return {
        key: value
        for key, value in item_neighbors.items()
        if len(value) != 0
    }

def get_n_best_neighbors(
    neighbors: dict,
    best_neighbor_count: int = NEIGHBORS_COUNT_DEFAULT
):
    # Prune 
    max_count = max(1, best_neighbor_count)
    n_best_neighbors = {
        neighbor_id: dict(
            [
                item
                for item in sorted(
                    neighbors[neighbor_id].items(), 
                    key=lambda x: x[1], 
                    reverse=True
                )[:max_count]
            ] 
        )
        for neighbor_id in neighbors
    }

    return n_best_neighbors

def get_k_best_arbitrary_neighbors(
    order: list,
    neighbors: dict,
    n_suggestions: dict,
    n_best_neighbors: int,
):
    n_best_neighbors = get_n_best_neighbors(neighbors, n_best_neighbors)

    def get_best_neighbor(item_id: str):
        try:
            return n_best_neighbors[item_id]
        except KeyError:
            return {}

    all_suggestions = list(
        set(
            flatten_list(
                [
                    list(get_best_neighbor(item_id).keys()) for item_id in order
                ]
            )
        )
    )
    
    suggestions = all_suggestions[:n_suggestions]
    
    return list(set(suggestions) - set(order))

def get_k_best_random_neighbors(
    order: list,
    neighbors: dict,
    n_suggestions: dict,
    n_best_neighbors: int,
):
    n_best_neighbors = get_n_best_neighbors(neighbors, n_best_neighbors)

    def get_best_neighbor(item_id: str):
        try:
            return n_best_neighbors[item_id]
        except KeyError:
            return {}

    all_suggestions = list(
        set(
            flatten_list(
                [
                    list(get_best_neighbor(item_id).keys()) for item_id in order
                ]
            )
        )
    )
    
    suggestions = sample(all_suggestions, n_suggestions)
    
    return list(set(suggestions) - set(order))

def get_k_best_support_based_neighbors(
    order: list,
    neighbors_: dict,
    sets_count_dict: dict,
    n_suggestions: dict,
    n_best_neighbors: int,
):
    sets_total = len(neighbors_.keys())
    
    n_best_neighbors = get_n_best_neighbors(neighbors_, n_best_neighbors)

    def get_best_neighbor(item_id: str):
        try:
            return n_best_neighbors[item_id]
        except KeyError:
            return {}

    count_dict = defaultdict()
    for neighbor_id, count in flatten_list(
        [
            list(get_best_neighbor(item_id).items()) 
            for item_id in order
        ]
    ):
        try:
            count_dict[neighbor_id] = max(count_dict[neighbor_id], count)
        except KeyError:
            count_dict[neighbor_id] = count            
    
    suggestion = [
        best_neighbor_j
        for best_neighbor_j, count_j in sorted(
            count_dict.items(), 
            key=lambda x: x[1], 
            reverse=True
        )
    ][:n_suggestions]

    return list(set(suggestion) - set(order))

def get_neighbors_count_per_item(
    df: pl.DataFrame, 
    sets_column: str, 
    item_column: str
):
    # Group by 'prod_id' and collect a list of 'pedi_id' for each group
    grouped = df.group_by(item_column).agg(sets_column)
    
    # Create an empty DataFrame to store the product co-occurrence counts
    final_df_cols = {
        item_column: str,
        "neighbors": str, 
        "count": int
    }
    count_df = pl.DataFrame(schema=final_df_cols, orient='col')
    
    # Iterate over each group
    for prod_id, pedi_ids in grouped.rows():
        
        # Filter the DataFrame to rows with pedi_ids in the current group
        filtered_df = df.filter(pl.col(sets_column).is_in(pedi_ids))
        
        # Calculate co-occurrence counts for each pedi_id in the group
        cooccurrence_counts = filtered_df.group_by(item_column)\
                                         .count()\
                                         .filter(pl.col(item_column) != prod_id)
        
        # Reshape the co-occurrence counts for each pedi_id into separate rows
        cooccurrence_tuples = [
            (prod_id, row[0], row[1]) 
            for row in cooccurrence_counts.rows()
        ]
        
        # Append co-occurrence counts for the current group to the result DataFrame
        this_prod_df = pl.DataFrame(cooccurrence_tuples, schema=final_df_cols)
        
        count_df = pl.concat([count_df, this_prod_df])

    return count_df

def get_frequent_items_and_rules_dict(
    filename_: str,
    df_: pd.DataFrame, 
    min_support_: float, 
    min_threshold_: float
):
    frequent_itemsets, rules = get_association_rules(
        df_, min_support_, min_threshold_
    )

    if(not rules.empty):
        create_folder('rules')
        new_filename = extend_filename(filename_, rules)
        rules.to_excel(new_filename)
    
    return {
        'frequent_itemsets': frequent_itemsets,
        'association_rules': rules
    }

@timer()
def get_association_rules(
    df_: pd.DataFrame, sets_column: str, items_column: str,
	min_support_=0.001,	min_threshold_=0.05, set_size_confidence=MIN_SET_SIZE_CONFIDENCE,
    is_verbose=True
):
    all_sets_list = listify_items(df_, sets_column, items_column)
    len_map = lambda x: len(x)
    len_sets = list(
        map(len_map, listify_items(df_, sets_column, items_column))
    )
    
    percentile_X = quantile(len_sets, set_size_confidence)
    confidence_data = list(filter(lambda x: len(x) < percentile_X, all_sets_list))
    
    # Preparação dos dados
    te = TransactionEncoder()
    te_ary = te.fit(confidence_data).transform(confidence_data)

    df_encoded = pd.DataFrame(te_ary, columns=te.columns_)
    
    # Aplicando o algoritmo Apriori
    frequent_itemsets = apriori(df_encoded, min_support=min_support_, use_colnames=True)
    
    # Geração de Regras de Associação
    relevant_columns = ['antecedents', 'consequents', 'support', 'confidence', 'lift']
    rules = association_rules(frequent_itemsets, metric = "confidence", min_threshold = min_threshold_)

    if(is_verbose):
        print(f'Comprimento de pedidos originais : {len(all_sets_list)}')
        print(f'Comprimento de pedidos de treino : {len(confidence_data)}')
        print(f'Número de regras                 : {len(rules)}')
        print()
    
    return frequent_itemsets, rules[relevant_columns]