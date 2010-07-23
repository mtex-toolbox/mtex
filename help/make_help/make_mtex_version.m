function make_mtex_version

dom = com.mathworks.xml.XMLUtils.createDocument('mtex');

struct2DOMnode(dom, dom.getDocumentElement,get_mtex_option('version'),'version')

xmlwrite('mtex_version.xml',dom)