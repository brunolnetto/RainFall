import styled, { css } from 'styled-components'

export const Wrapper = styled.div`
    ${({ theme }) => css`
        background: ${theme.colors.primaryLightest};
        border-left: 5px solid ${theme.colors.primary};
        display: flex;
        flex-direction: column;
        padding: ${theme.spacings.xsmall};
    `}
`

export const Header = styled.header`
    ${({ theme }) => css`
        border-bottom: 1px solid ${theme.colors.primary};
        display: flex;
        flex-direction: column;
        margin-bottom: ${theme.spacings.xsmall};
    `}
`

export const MessageItem = styled.div`
    ${({ theme }) => css`
        display: flex;
        margin-bottom: ${theme.spacings.xxsmall};
    `}
`