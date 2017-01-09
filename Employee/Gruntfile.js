module.exports = function(grunt) {
	require('load-grunt-tasks')(grunt);
	grunt
			.initConfig({
				compress : {
					main : {
						options : {
							archive : 'Employees-dist.zip',
							pretty : true
						},
						exclusions : [ '.gitignore', 'Gruntfile.js' ],
						expand : true,
						cwd : './',
						src : [ 'index.html', '*.png', '*.php', 'manifest.json' ],
						dest : './'
					}
				}
			});

	grunt.registerTask('default', [ 'compress' ]);
};
