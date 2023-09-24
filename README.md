This is a simple migration script for migrating from nyxx 5.x.x to nyxx 6.0.0.

It automates many of the simple renamings and substitution changes as well as a few common complex changes.

## Running from the dill file

1. Download the `rewriter.dill` file. This file contains a partially compiled version of `rewriter.dart` which can be run directly by dart.
2. Run `dart run path/to/rewriter.dill path/to/project/` where `path/to/project/` is the path of the project you want to migrate.

The script will output into a directory called `migrated` in the same directory as the directory containing your project. We recommend using git and having a clean working tree (all changes committed) when you run the migration script so you can review the changes made by the script.

## Running from sources

1. Download the `rewriter.dart` and `pubspec.yaml` files into an empty directory.
2. Run `dart pub get` in the directory.
3. Run `dart run path/to/rewriter.dart path/to/project/` where `path/to/project/` is the path of the project you want to migrate.

The script will output into a directory called `migrated` in the same directory as the directory containing your project. We recommend using git and having a clean working tree (all changes committed) when you run the migration script so you can review the changes made by the script.
