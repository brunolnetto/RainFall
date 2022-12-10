const themeDefault = {
    colors: {
      primary: '#0B8384',
      primaryLightest: '#D9EDEC',
      primaryLight: '#0AAEA6',
      primaryDark: '#0A5860',
      secondary: '#163A63',
      red: '#F06466',
      redLight: '#FFEDEE',
      yellow: '#FAC11E',
      yellowLight: '#FBF2E5',
      gray: '#737373',
      grayLight: '#F4F4F4',
      grayDark: '#424242', //text
      offwhite: '#F8F5F0',
      white: '#ffffff',
      black: '#222222'
    },
    font: {
      family: {
        normal:
          "Open Sans, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif",
        heading:
          "Ubuntu, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif"
      },
      sizes: {
        xxsmall: '1rem', // xs
        xsmall: '1.2rem', // sm
        small: '1.4rem', // base
        medium: '1.6rem', // md
        large: '1.8rem', // lg
        xlarge: '2.4rem', // xl
        xxlarge: '3.2rem' // xxl
      },
      weight: {
        light: 300,
        normal: 400, // base
        bold: 700
      },
      height: {
        medium: 1.4, // base
        heading: 1.2
      }
    },
    spacings: {
      xxsmall: '0.4rem', // xxs
      xsmall: '0.8rem', // xs
      small: '1.6rem', // sm
      medium: '2.4rem', // base
      large: '3.2rem', // md
      xlarge: '4.8rem', // lg
      xxlarge: '6.4rem' // xlg
    },
    layers: {
      base: 10,
      menu: 20,
      overlay: 30,
      modal: 40,
      alwaysOnTop: 50
    },
    border: {
      radius: '0.4rem'
    },
    transition: {
      default: '0.3s ease-in-out',
      fast: '0.1s ease-in-out'
    },
    shadow: {
      card: '0px 1px 6px 1px rgba(142, 142, 142, 0.16)',
      cardElevated: '0px 2px 6px 2px rgba(142, 142, 142, 0.32)',
      header: '0px 4px 4px rgba(142, 142, 142, 0.15)'
    }
  }
  
  export default themeDefault