import React from 'react'

import * as S from './styles'

const Typography = ({ tag, children, spacing, variant, align, ...props }) => (
  <S.Wrapper
    variant={variant}
    tag={tag}
    align={align}
    spacing={spacing}
    {...props}
  >
    {children}
  </S.Wrapper>
)

Typography.defaultProps = {
  tag: 'text',
  variant: 'primary',
  align: 'start',
  spacing: ''
}

export default Typography
