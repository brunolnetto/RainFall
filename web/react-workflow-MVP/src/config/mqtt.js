import { nanoid } from "nanoid"

const clientId = nanoid()

const MQTT = {
    host: process.env.REACT_APP_MQTT_HOST,
    port: parseInt(process.env.REACT_APP_MQTT_PORT),
    clientId: clientId
}

export default MQTT