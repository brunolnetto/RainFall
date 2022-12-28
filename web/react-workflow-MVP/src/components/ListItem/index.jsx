import React from 'react'

import Typography from '../Typography'

import * as S from './styles'

const ListItem = ({ item, onClick }) => (
    <S.ListItem onClick={onClick}>
        <Typography tag="h5">{item?.name}</Typography>
        <Typography tag="disclaimer">{item?.description}</Typography>
        <Typography tag="disclaimer">Versão: {item?.version}</Typography>
    </S.ListItem>
)

export default ListItem