--[[
	Entities list by Walter Cruz.
	Library by _FR_Starfox64.
]]--

htmlentities = {}

htmlentities.entities = {
	[" "] = "&nbsp;",
	["¡"] = "&iexcl;",
	["¢"] = "&cent;",
	["£"] = "&pound;",
	["¤"] = "&curren;",
	["¥"] = "&yen;",
	["¦"] = "&brvbar;",
	["§"] = "&sect;",
	["¨"] = "&uml;",
	["©"] = "&copy;",
	["ª"] = "&ordf;",
	["«"] = "&laquo;",
	["¬"] = "&not;",
	["­"] = "&shy;",
	["®"] = "&reg;",
	["¯"] = "&macr;",
	["°"] = "&deg;",
	["±"] = "&plusmn;",
	["²"] = "&sup2;",
	["³"] = "&sup3;",
	["´"] = "&acute;",
	["µ"] = "&micro;",
	["¶"] = "&para;",
	["·"] = "&middot;",
	["¸"] = "&cedil;",
	["¹"] = "&sup1;",
	["º"] = "&ordm;",
	["»"] = "&raquo;",
	["¼"] = "&frac14;",
	["½"] = "&frac12;",
	["¾"] = "&frac34;",
	["¿"] = "&iquest;",
	["À"] = "&Agrave;",
	["Á"] = "&Aacute;",
	["Â"] = "&Acirc;",
	["Ã"] = "&Atilde;",
	["Ä"] = "&Auml;",
	["Å"] = "&Aring;",
	["Æ"] = "&AElig;",
	["Ç"] = "&Ccedil;",
	["È"] = "&Egrave;",
	["É"] = "&Eacute;",
	["Ê"] = "&Ecirc;",
	["Ë"] = "&Euml;",
	["Ì"] = "&Igrave;",
	["Í"] = "&Iacute;",
	["Î"] = "&Icirc;",
	["Ï"] = "&Iuml;",
	["Ð"] = "&ETH;",
	["Ñ"] = "&Ntilde;",
	["Ò"] = "&Ograve;",
	["Ó"] = "&Oacute;",
	["Ô"] = "&Ocirc;",
	["Õ"] = "&Otilde;",
	["Ö"] = "&Ouml;",
	["×"] = "&times;",
	["Ø"] = "&Oslash;",
	["Ù"] = "&Ugrave;",
	["Ú"] = "&Uacute;",
	["Û"] = "&Ucirc;",
	["Ü"] = "&Uuml;",
	["Ý"] = "&Yacute;",
	["Þ"] = "&THORN;",
	["ß"] = "&szlig;",
	["à"] = "&agrave;",
	["á"] = "&aacute;",
	["â"] = "&acirc;",
	["ã"] = "&atilde;",
	["ä"] = "&auml;",
	["å"] = "&aring;",
	["æ"] = "&aelig;",
	["ç"] = "&ccedil;",
	["è"] = "&egrave;",
	["é"] = "&eacute;",
	["ê"] = "&ecirc;",
	["ë"] = "&euml;",
	["ì"] = "&igrave;",
	["í"] = "&iacute;",
	["î"] = "&icirc;",
	["ï"] = "&iuml;",
	["ð"] = "&eth;",
	["ñ"] = "&ntilde;",
	["ò"] = "&ograve;",
	["ó"] = "&oacute;",
	["ô"] = "&ocirc;",
	["õ"] = "&otilde;",
	["ö"] = "&ouml;",
	["÷"] = "&divide;",
	["ø"] = "&oslash;",
	["ù"] = "&ugrave;",
	["ú"] = "&uacute;",
	["û"] = "&ucirc;",
	["ü"] = "&uuml;",
	["ý"] = "&yacute;",
	["þ"] = "&thorn;",
	["ÿ"] = "&yuml;",
	["\""] = "&quot;",
	["\'"] = "&#39;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	["&"] = "&amp;"
}

--[[
	Converts HTML Entities into their proper symbol.
	@arg1-> string to process
	@return-> processed string
]]--
function htmlentities.convertEntities( text )
	for replacement, entity in pairs(htmlentities.entities) do
		for entity, replacement in pairs(self.htmlEntities) do
			text = string.Replace(text, entity, replacement)
		end
	end

	return text
end