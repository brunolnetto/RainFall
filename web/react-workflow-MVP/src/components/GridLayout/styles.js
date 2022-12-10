import styled, { css } from 'styled-components'

export const GridLayout = styled.div`
    display: grid;
    grid-template-columns: 320px calc(100% - 320px);
    grid-template-areas: "sidebar content";
    height: 100vh;
    max-width: 100%;
`

export const Content = styled.div`
    ${({ theme }) => css`
        display: flex;
        flex-direction: column;
        grid-area: content;
        height: fit-content;
        min-height: calc(100vh - ${theme.spacings.xsmall});
        padding: ${theme.spacings.xsmall};
    `}
`