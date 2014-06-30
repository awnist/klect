## What is "klect"?

Klect is a node module that will collect and enumerate groups of assets. 

## Install

    $ npm install klect

## Basic usage

    var bundles = {
        "mobile.css": ['modules/**/*.mobile.{less,css}']
        "desktop.css": ['modules/**/*.{less,css}']
        "site.js": [
            'modules/angular/angular.js',
            'modules/**/*.js'
        ]
    }
    
    var assets = new klect().gather(bundles);
    
    // List files
    console.log(assets.files());
    
    // List only "site.js" files
    console.log(assets.bundles("site.js").files())
    
    // List only "site.js" URL paths
    console.log(assets.bundles("site.js").urls())

Note that assets are collected in a first come / first claim basis.

In the example above, 

        "mobile.css": ['modules/**/*.mobile.{less,css}']
        "desktop.css": ['modules/**/*.{less,css}']

desktop.css will ignore any files already claimed by mobile.css.

This also applies within a single bundle:

        "site.js": [
            'modules/angular/angular.js',
            'modules/**/*.js'

Here, angular will always be loaded first, and the *.js glob will ignore angular so there will be no duplicates.

If there's a file you need included in every bundle every time, like a .less mixin, just preface the path with a "!":

        "mobile.css": [
            '!modules/styles/mixins.less'
            'modules/**/*.mobile.{less,css}'
        ]
        "desktop.css": [
            '!modules/styles/mixins.less'
            'modules/**/*.{less,css}'
        ]

You may have also guessed by now that path specifications can be literal
    
    'foo/bar.js'

or [glob](https://github.com/isaacs/node-glob)

    'foo/**/bar.*'

Klect is also good for server-side modules:
    
    var files = new klect().gather(['modules/server/*']).files()
    for (var i = 0; i < files.length; i++) {
        require(files[i]);
    }

## Advanced usage

Set path base and web url base:

    var assets = new klect({
        cwd: "./",
        urlcwd: "/"
    }).gather(bundles);

Get a specific bundle:

    console.log(assets.bundles("site.js"));

Or a list of bundles by glob name):

    console.log(assets.bundles("site.*"));

## Integrations

### Express / web views

First, create a helper function for your views:

    var assets = new klect().gather(bundles);

    app.locals.scripts = function(bundleName){
        // In production, just reference the bundle name, like "site.js"
        // otherwise, load each script individually.
        var scripts = environment === "production" ? [bundleName] : assets.bundles(bundleName).urls();

        var output = "";
        for (var i = 0; i < scripts.length; i++) {
            output += '<script src="'+ scripts[i] +'" type="text/javascript"></script>'
        }
        return output;
    }

**index.jade**

    html
        head
            !=scripts("head.js")
        body
            h1 Example page
            !=scripts("site.js")

### Build systems

**Gulp**

This will build every script for production environments by bundle name.

    var assets = new klect().gather(bundles);

    gulp.task('scripts', function(){
        var scripts = assets.bundles('*.js');
        
        for (var i = 0; i < scripts.length; i++) {
            gulp
            .src(scripts[i].files)
            .pipe(concat(js.name))
            .pipe(uglify())
            .pipe(gulp.dest('./build/'));
        }
    })

## License

klect is [UNLICENSED](http://unlicense.org/).
