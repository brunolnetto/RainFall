import axios from 'axios'
import { login } from '../services/loginService'

const api = axios.create({
    baseURL: process.env.REACT_APP_BASE_URL,
    timeout: 180000
})

api.interceptors.request.use(
    async (config) => {
      const token = await login()
      if (token) {
        config.headers.Authorization = `Bearer ${token}`
      }
      return config
    },
    (error) => {
      console.error('Interceptors Request ->', `${error.name}: ${error.message}`)
    }
  )
  
  export default api