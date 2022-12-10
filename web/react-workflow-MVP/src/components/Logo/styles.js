import styled, { css } from 'styled-components'

export const Wrapper = styled.div`
    ${({ theme }) =>  css`
        align-items: center;
        display: flex;
        height: 90px;
        justify-content: center;
        padding: ${theme.spacings.xsmall};
        width: 100%auto;
    `}
`

export const Image = styled.img`
    max-width: 100%;
    width: 80%;
`