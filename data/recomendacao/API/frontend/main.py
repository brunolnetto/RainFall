####################################################################
# Bibliotecas
####################################################################
import streamlit as st
from warnings import simplefilter
from os import path
from st_aggrid import AgGrid

from core import obter_dados_de_vendas
from interface import exibir_carrinho, \
    exibir_sugestoes, \
    exibir_menu_de_selecao, \
    exibir_painel_de_metricas

####################################################################
# Configuração
####################################################################

# Suppress FutureWarning messages
warnings_=(FutureWarning, DeprecationWarning)
simplefilter(action='ignore', category=warnings_)

###################### Carregamento de dados #####################
data_rootpath = path.dirname(__file__) 
itens_mais_vendidos, trends = obter_dados_de_vendas(data_rootpath)

###################### Interface do Usuário ######################

st.write("# Suas Vendas ")
st.write("## Adivinhando o próximo Item: ")

# Botão que limpa o estado do aplicativo
if st.sidebar.button('Reboot'):
    st.session_state.resultado = None
    st.cache_data.clear()
    st.sidebar.write('O estado do aplicativo foi limpo.')

exibir_menu_de_selecao(itens_mais_vendidos)
exibir_painel_de_metricas(trends)

###### Carrinho de Compras
coluna_item = "Produto"

st.write("#### Carrinho de Compras")
carrinho = exibir_carrinho(itens_mais_vendidos, coluna_item)

if not carrinho.empty:
    st.sidebar.write("Leve também: ")
    exibir_sugestoes(carrinho, trends, coluna_item )

if carrinho is not None:
    st.write("Meu Carrinho final de Compras:")
    AgGrid(carrinho, height=250)




 

