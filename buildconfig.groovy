
goldenMaster {
    sourcePath = 'src/'
    targetPath = 'build/src_gen/'

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
formats = [
    'asciidoc': [imageFolder: true],
    'html': [imageFolder: true],
    'epub': [imageFolder: false],
    'markdown': [imageFolder: true],
    'textile': [imageFolder: true],
    'docx': [imageFolder: false],
    'docbook': [imageFolder: true]
]

distribution {
    targetPath = "build/dist/"
    //formats = ['asciidoc','html','epub','markdown','docx','docbook']
}

