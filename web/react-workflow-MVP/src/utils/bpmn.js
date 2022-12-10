import { is } from "bpmn-js/lib/util/ModelUtil";

export const hasDefinition = (event, definitionType) => {
    const definitions = event.businessObject.eventDefinitions || [];

    return definitions.some(d => is(d, definitionType));
} 