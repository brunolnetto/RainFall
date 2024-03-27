import streamlit as st
import pandas as pd

from st_aggrid import AgGrid

from core import salvar_carrinho, \
            sugerir_items, \
            remover_item_no_carrinho

from utils.dataframe import obter_dataframe_com_selecoes, \
    adicionar_item_a_lista

from core import salvar_carrinho, \
            sugerir_items, \
            remover_item_no_carrinho, \
            sugestao_inicial, \
            obter_carrinho

from utils.dataframe import obter_dataframe_com_selecoes, \
    adicionar_item_a_lista

from constants import DEFAULT_ITEM_COUNT

def exibir_menu_de_selecao(itens_mais_vendidos):
    # Define widget para quantidade de entradas vendidas
    user_input = st.number_input(
        'Inserir o número de items no display:', 
        min_value=DEFAULT_ITEM_COUNT, max_value=len(itens_mais_vendidos)
    )

    amostra_msg = f"#### Vendas (amostra de {user_input} itens mais vendidos)"
    st.write(amostra_msg)   

    AgGrid(
        itens_mais_vendidos.head(user_input), 
        height=300 , width=1600, fit_columns_on_grid_load=True
    )

def exibir_carrinho(
        itens_mais_vendidos: pd.DataFrame,
        coluna_item: str
    ):
    st.sidebar.write("Produtos mais vendidos: ")
    sugestao_mais_vendidos = sugestao_inicial(
        itens_mais_vendidos, coluna_item, 
        top_=15, n_itens=10
    )

    selection = obter_dataframe_com_selecoes(
        sugestao_mais_vendidos, 
        key="Mais_vendidos"
    )

    items_atuais = obter_carrinho(coluna_item)
    carrinho = adicionar_item_a_lista(items_atuais, item=selection) 
    salvar_carrinho(carrinho, coluna_item)

    return carrinho

def exibir_sugestoes(
        carrinho: pd.DataFrame,
        trends: pd.DataFrame,
        coluna_item: str
):
    sugestoes = sugerir_items(
        lista=carrinho, 
        trends=trends,
        coluna_item=coluna_item
    )
    
    sugestoes = remover_item_no_carrinho(sugestoes, coluna_item)
    item_novo = obter_dataframe_com_selecoes(sugestoes, key="Sugestões")
    carrinho = adicionar_item_a_lista(carrinho, item=item_novo)      
    
    salvar_carrinho(carrinho, coluna_item)

def exibir_painel_de_metricas(
    trends: pd.DataFrame
):
    with st.expander("Métricas de associação", expanded=False):
        lift_definition = 'Probabilidade de itens serem levados juntos.'
        lift_explanation = 'Valor maior que 1 indica maior possibilidade e menor do 1 indicam aversão' 
        zhang_definition = 'Idem acima.'
        zhang_explanation = 'Valor maior que 1 indica maior possibilidade e menor do 1 indicam aversão'
        
        metrics_explained="""<p>Indicadores:</p>
            <li>Lift: {lift_definition}{lift_explanation}</li>
            <li>Zhang's Metric: {zhang_definition}{zhang_explanation}</li>
        """.format(
            lift_definition=lift_definition,
            lift_explanation=lift_explanation, 
            zhang_definition=zhang_definition,
            zhang_explanation=zhang_explanation
        )
        
        st.write(metrics_explained, unsafe_allow_html=True)

        AgGrid(trends, height=300, fit_columns_on_grid_load=True)