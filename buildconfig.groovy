sourcePath = 'src/DE/asciidoc/'
targetPath = 'src_gen/DE/asciidoc/'

goldenMaster {
    // a list of all features contained in the golden master
    allFeatures = ['help', 'example']

    // style: list of features
    templateStyles = [
            'plain'    : [],
            'with-help': ['help'],
            // deaktivated for the moment - no content yet
            // 'with-examples':['help','example'],
    ]
}

distribution {
    targetPath = "build/dist/"
    //formats = ['asciidoc','html','epub','markdown','docx','docbook']
    formats = ['asciidoc','html']
}