//@ui5-bundle cap/fe/capfe/Component-preload.js
jQuery.sap.registerPreloadedModules({
"version":"2.0",
"modules":{
	"cap/fe/capfe/Component.js":function(){sap.ui.define(["sap/fe/core/AppComponent"],function(e){"use strict";return e.extend("cap.fe.capfe.Component",{metadata:{manifest:"json"}})});
},
	"cap/fe/capfe/i18n/i18n.properties":'# This is the resource bundle for cap_fe\n\n#Texts for manifest.json\n\n#XTIT: Application name\nappTitle=App Title\n\n#YDES: Application description\nappDescription=A Fiori application.\n',
	"cap/fe/capfe/manifest.json":'{"_version":"1.32.0","sap.app":{"id":"cap.fe.capfe","type":"application","i18n":"i18n/i18n.properties","applicationVersion":{"version":"1.0.0"},"title":"{{appTitle}}","description":"{{appDescription}}","dataSources":{"mainService":{"uri":"executive/","type":"OData","settings":{"odataVersion":"4.0"}}},"offline":false,"resources":"resources.json","sourceTemplate":{"id":"ui5template.fiorielements.v4.lrop","version":"1.0.0"}},"sap.cloud":{"public":true,"service":"business.service"},"sap.ui":{"technology":"UI5","icons":{"icon":"","favIcon":"","phone":"","phone@2":"","tablet":"","tablet@2":""},"deviceTypes":{"desktop":true,"tablet":true,"phone":true}},"sap.ui5":{"resources":{"js":[],"css":[]},"dependencies":{"minUI5Version":"1.98.0","libs":{"sap.ui.core":{},"sap.fe.templates":{}}},"models":{"@i18n":{"type":"sap.ui.model.resource.ResourceModel","uri":"i18n/i18n.properties"},"i18n":{"type":"sap.ui.model.resource.ResourceModel","uri":"i18n/i18n.properties"},"":{"dataSource":"mainService","preload":true,"settings":{"synchronizationMode":"None","operationMode":"Server","autoExpandSelect":true,"earlyRequests":true}}},"routing":{"routes":[{"pattern":":?query:","name":"AccountsList","target":"AccountsList"},{"pattern":"Accounts({key}):?query:","name":"AccountsObjectPage","target":"AccountsObjectPage"},{"pattern":"Accounts({key})/transactions({key2}):?query:","name":"TransactionsObjectPage","target":"TransactionsObjectPage"}],"targets":{"AccountsList":{"type":"Component","id":"AccountsList","name":"sap.fe.templates.ListReport","options":{"settings":{"entitySet":"Accounts","variantManagement":"Page","navigation":{"Accounts":{"detail":{"route":"AccountsObjectPage"}}}}}},"AccountsObjectPage":{"type":"Component","id":"AccountsObjectPage","name":"sap.fe.templates.ObjectPage","options":{"settings":{"editableHeaderContent":false,"entitySet":"Accounts","navigation":{"transactions":{"detail":{"route":"TransactionsObjectPage"}}}}}},"TransactionsObjectPage":{"type":"Component","id":"TransactionsObjectPage","name":"sap.fe.templates.ObjectPage","options":{"settings":{"editableHeaderContent":false,"entitySet":"Transactions"}}}}},"contentDensities":{"compact":true,"cozy":true}},"sap.platform.abap":{"_version":"1.1.0","uri":""},"sap.platform.hcp":{"_version":"1.1.0","uri":""},"sap.fiori":{"_version":"1.1.0","registrationIds":[],"archeType":"transactional"}}'
}});
