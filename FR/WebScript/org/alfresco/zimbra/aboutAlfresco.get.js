<import resource="/Espace racine/Dictionnaire de données/Extensions de Web Scripts/org/alfresco/util/alfcommon.js">

var result = {};

result.version = server.version;

result.edition = server.edition;

result.userId = person.properties.userName;

result.fullName = person.properties.firstName + person.properties.lastName;

// model.result = result.toJSONString();
model.result = jsonUtils.toJSONString(result);

