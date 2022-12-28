import styled, { css } from 'styled-components'

export const Wrapper = styled.div`
    ${({ theme }) =>  css`
        border-right: 1px ${theme.colors.grayLight} solid;
        grid-area: sidebar;
    `}
`

export const List = styled.ul`
    ${({ theme }) =>  css`
        width: 100%;
    `}
`