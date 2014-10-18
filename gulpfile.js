var gulp = require('gulp');
var gutil = require('gulp-util');
var concat = require('gulp-concat')
var sass = require('gulp-sass');
var coffee = require('gulp-coffee');
var shell = require('gulp-shell');
//var spawn = require('child_process').spawn;

gulp.task('default', ['sass', 'coffee']);


gulp.task('sass', function () {
    gulp.src('./www/scss/app.scss')
            .pipe(sass({ sourceComments: 'normal' }).on('error', gutil.log).on('error', gutil.beep))
            .pipe(gulp.dest('./www/css'));
});


gulp.task('coffee', function() {
  gulp.src('./www/coffee/**/*.coffee')
          .pipe(coffee({ bare: true, compile: true, sourceMap: false, join: true }).on('error', gutil.log).on('error', gutil.beep))
          .pipe(concat('app.js'))
          .pipe(gulp.dest('./www/js'))
});



gulp.task('cordova-prepare-android', shell.task(['cordova prepare android']));
//function() {
//  var child = spawn('cordova prepare android', [], { cwd: process.cwd() });
//  child.stdout.setEncoding('utf8');
//  child.stdout.on('data', function (data) {
//    gutil.log(data);
//  });
//
//  child.stderr.setEncoding('utf8');
//  child.stderr.on('data', function (data) {
//    gutil.log(gutil.colors.red(data));
//    gutil.beep();
//  });
//
//  child.on('close', function(code) {
//    gutil.log("Done with exit code", code);
//  });
//});



gulp.task('watch', ['coffee', 'sass'], function() {
  gulp.watch('www/coffee/**/*.coffee', ['coffee']).on('change', function (event) {
    gutil.log(event.type + ': '+event.path);
  });
  gulp.watch('www/scss/**/*', ['sass']).on('change', function (event) {
    gutil.log(event.type + ': '+event.path);
  });


//  gulp.watch('www/**/*', ['cordova-prepare-android']).on('change', function (event) {
//    gutil.log('www changed: '+ event.type + ': '+event.path);
//  });

});
