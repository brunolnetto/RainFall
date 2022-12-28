import styled, { css } from 'styled-components'

const wrapperModifiers = {
  h1: (theme, variant) => css`
    color: ${variant === 'primary'
      ? theme.colors.secondary
      : theme.colors.grayDark};
    font-size: ${theme.font.sizes.xxlarge};
  `,
  h2: (theme, variant) => css`
    color: ${variant === 'primary'
      ? theme.colors.secondary
      : theme.colors.grayDark};
    font-size: ${theme.font.sizes.xlarge};
  `,
  h3: (theme, variant) => css`
    color: ${variant === 'primary'
      ? theme.colors.secondary
      : theme.colors.grayDark};
    font-size: ${theme.font.sizes.large};
  `,
  h4: (theme, variant) => css`
    color: ${variant === 'primary' ? theme.colors.grayDark : theme.colors.gray};
    font-size: ${theme.font.sizes.medium};
  `,
  h5: (theme, variant) => css`
    color: ${variant === 'primary'
      ? theme.colors.grayDark
      : theme.colors.secondary};
    font-size: ${theme.font.sizes.small};
  `,

  h6: (theme, variant) => css`
    color: ${theme.colors.primary};
    color: ${variant === 'primary'
      ? theme.colors.primary
      : theme.colors.secondary};
    font-size: ${theme.font.sizes.small};
  `,
  text: (theme, variant) => css`
    color: ${variant === 'primary'
      ? theme.colors.grayDark
      : theme.colors.primary};
    font-size: ${theme.font.sizes.small};
  `,
  support: (theme, variant) => css`
    color: ${variant === 'primary' ? theme.colors.gray : theme.colors.primary};
    font-size: ${theme.font.sizes.xsmall};
  `,
  disclaimer: (theme, variant) => css`
    color: ${variant === 'primary' ? theme.colors.gray : theme.colors.primary};
    font-size: ${theme.font.sizes.xxsmall};
  `,
  label: (theme) => css`
    color: ${theme.colors.gray};
    font-family: ${theme.font.family.normal};
    font-size: ${theme.font.sizes.xxsmall};
    text-transform: uppercase;
  `,
  heading: (theme) => css`
    font-family: ${theme.font.family.heading};
    font-weight: ${theme.font.weight.bold};
    line-height: ${theme.font.height.heading};
  `,
  normal: (theme) => css`
    font-family: ${theme.font.family.normal};
    font-weight: ${theme.font.weight.normal};
    line-height: ${theme.font.height.medium};
  `
}

const tags = ['text', 'support', 'disclaimer', 'heading']

export const Wrapper = styled('p').attrs(({ tag }) => ({
  as: `${tags.includes(tag) ? 'p' : tag}`
}))`
  ${({ theme, tag, variant, spacing, align }) => css`
    margin-bottom: ${spacing === '' ? 0 : `${theme.spacings[spacing]}`};
    text-align: ${align};

    ${!tags.includes(tag) && wrapperModifiers.heading(theme)}
    ${tags.includes(tag) && wrapperModifiers.normal(theme)}
    ${!!tag && wrapperModifiers[tag](theme, variant)}
  `}
`
