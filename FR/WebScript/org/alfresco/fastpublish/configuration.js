/**
 * Configuration and filters for node listing services
 */

// list of hidden folders
var hiddenFolders = new Array();
hiddenFolders[0] = "Dictionnaire de données";
//hiddenFolders[1] = "Sites";

// default root space for lists
var defaultRootSpaceName = "Espace Utilisateurs";

// default upload folder
var defaultUploadFolder = userhome;

// TODO: hide read-only folders in Save to Alfresco lista
var hideReadOnlyFolders = true;
	
/*
 * Search for hidden folder matching...
 */
function isHiddenFolder(folderName) {
	for(var i=0; i<hiddenFolders.length; i++) {
		if( (folderName.toString()) == (hiddenFolders[i].toString()) ) {
			return(true);
		}
	}
	return(false);
}
