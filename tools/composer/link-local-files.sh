#!/bin/bash

#
# Call like so, for non-standard locations like in capistrano:
# CODEBASE_DIRECTORY="/path/to/installation/" php composer.phar install
#
if [ -z "$CODEBASE_DIRECTORY" ]; then
    CODEBASE_DIRECTORY='../'
fi
if [ -z "$INSTALLATION_STRATEGY" ]; then
    INSTALLATION_STRATEGY='symlink'
fi

if [ "$INSTALLATION_STRATEGY" == "copy" ]; then
    echo "Using installation strategy 'copy'"
else
    echo "Using installation strategy 'symlink'"
fi

TARGET_INSTALLATION_DIRECTORY="$(pwd)/../http"

symlink() {
    parent_directory=${1%/*}
    target_subdirectory=$1
    source_location=$2

    if [ "$parent_directory" == "$target_subdirectory" ]; then
        parent_directory="."
    fi

    echo "$TARGET_INSTALLATION_DIRECTORY/$target_subdirectory"
    if [ ! -e "$TARGET_INSTALLATION_DIRECTORY/$target_subdirectory" ]; then
        mkdir -p "$TARGET_INSTALLATION_DIRECTORY/$parent_directory"
        echo "$TARGET_INSTALLATION_DIRECTORY/$parent_directory || $source_location/src/$target_subdirectory"
        (cd "$TARGET_INSTALLATION_DIRECTORY/$parent_directory" && ln -sv "$source_location/src/$target_subdirectory" . )
    fi
}

copy() {
    parent_directory=${1%/*}
    target_subdirectory=$1

    if [ "$parent_directory" == "$target_subdirectory" ]; then
        parent_directory="."
    fi

    echo "$TARGET_INSTALLATION_DIRECTORY/$target_subdirectory"
    if [ ! -e "$TARGET_INSTALLATION_DIRECTORY/$target_subdirectory" ]; then
        mkdir -p "$TARGET_INSTALLATION_DIRECTORY/$parent_directory"
        (cd "$TARGET_INSTALLATION_DIRECTORY/$parent_directory" && rsync -a "$CODEBASE_DIRECTORY/src/$target_subdirectory" "." )
    fi
}

install_file() {
    if [ "$INSTALLATION_STRATEGY" == "copy" ]; then
        copy "$@"
    else
        symlink "$@"
    fi
}

if [ ! -d "$CODEBASE_DIRECTORY/src/" ]; then
    echo "ERROR: No codebase located at '$CODEBASE_DIRECTORY/src/'"
    exit 1
fi

pushd "$CODEBASE_DIRECTORY/src/"

#link modules present under app/code
find "app/code" -mindepth 3 -maxdepth 3 -type d -print0 | while read -d '' -r file; do
    install_file "$file" "../../../../.."
done

#add new modules config files under app/etc
find "app/etc/modules" -maxdepth 1 -type f -print0 | while read -d '' -r file; do
    install_file "$file" "../../../.."
done

#link packages
find "app/design" -mindepth 2 -maxdepth 2 -type d -print0 | while read -d '' -r file; do
    install_file "$file" "../../../.."
done

#link theme files
find "app/design" -mindepth 3 -maxdepth 3 -type d -print0 | while read -d '' -r file; do
    install_file "$file" "../../../../.."
done

#link adminhtml design files
find "app/design/adminhtml/default/default" -mindepth 2 -maxdepth 2  -print0 | while read -d '' -r file; do
    install_file "$file" "../../../../../../../"
done

#link adminhtml design files
find "app/design/adminhtml/default/default" -mindepth 3 -maxdepth 3  -print0 | while read -d '' -r file; do
    install_file "$file" "../../../../../../../../"
done

#link adminhtml design files
find "app/design/adminhtml/default/default" -mindepth 2 -maxdepth 2  -print0 | while read -d '' -r file; do
    install_file "$file" "../../../../../../../"
done

#link adminhtml design files
find "app/design/frontend/default/default" -mindepth 2 -maxdepth 2  -print0 | while read -d '' -r file; do
    install_file "$file" "../../../../../../../"
done

#link adminhtml design files
find "app/design/frontend/default/default" -mindepth 3 -maxdepth 3  -print0 | while read -d '' -r file; do
    install_file "$file" "../../../../../../../.."
done

#link adminhtml design files
find "app/design/frontend/base/default" -mindepth 1 -maxdepth 1  -print0 | while read -d '' -r file; do
    install_file "$file" "../../../../../../"
done

#link adminhtml design files
find "app/design/frontend/base/default" -mindepth 2 -maxdepth 2  -print0 | while read -d '' -r file; do
    install_file "$file" "../../../../../../.."
done


#link skin files
find "skin" -mindepth 2 -maxdepth 2 -type d -print0 | while read -d '' -r file; do
    install_file "$file" "../../.."
done

#link skin files
find "skin" -mindepth 3 -maxdepth 3 -type d -print0 | while read -d '' -r file; do
    install_file "$file" "../../../.."
done

#link js files
find "js" -mindepth 1 -maxdepth 1 -print0 | while read -d '' -r file; do
    install_file "$file" "../.."
done

#link js files
find "lib" -mindepth 1 -maxdepth 1 -print0 | while read -d '' -r file; do
    install_file "$file" "../.."
done

#link shell files
find "shell" -mindepth 1 -maxdepth 1 -print0 | while read -d '' -r file; do
    install_file "$file" "../.."
done

#link errors files
find "errors" -mindepth 1 -maxdepth 1 -print0 | while read -d '' -r file; do
    install_file "$file" "../.."
done

#trying to link email template files
find "app/locale" -mindepth 2 -maxdepth 2 -print0 | while read -d '' -r file; do
        install_file "$file" "../../../.."
done

#trying to link email template files
find "app/locale" -mindepth 4 -maxdepth 4 -type d -print0 | while read -d '' -r file; do
    if [[ "$file" == *"template/email"* ]]
    then
        install_file "$file" "../../../../../../"
    fi
done

#link other root files
find "." -mindepth 1 -maxdepth 1 ! -name "app" ! -name "js" ! -name "shell" ! -name "skin" ! -name "errors" -print0 | while read -d '' -r file; do
    install_file "${file##*/}" ".."
done

popd
