
DEST_DIR=./docker/base/assets

if [ "$1" = "clean" ]; then
    echo "Cleaning assets in ${DEST_DIR}"
    find "${DEST_DIR}" -mindepth 1 ! -path "${DEST_DIR}/.gitkeep" -delete
    exit 0
fi

if [ ! -d "${DEST_DIR}" ]; then
    mkdir -p "${DEST_DIR}"
fi


# conda
if [ ! -f "${DEST_DIR}/miniconda.sh" ]; then
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh" -O "${DEST_DIR}/miniconda.sh"
fi

# nvm
if [ ! -d "${DEST_DIR}/nvm" ]; then
    latest_nvm_tag="$(git ls-remote --refs --tags --sort='version:refname' https://github.com/nvm-sh/nvm.git | tail -n1 | sed 's|.*refs/tags/||')"
    if [ -z "${latest_nvm_tag}" ]; then
        echo "Failed to resolve latest nvm tag" >&2
        exit 1
    fi
    git clone --branch "${latest_nvm_tag}" --depth 1 --single-branch https://github.com/nvm-sh/nvm.git "${DEST_DIR}/nvm"
fi

# rust
if [ ! -f "${DEST_DIR}/rustup.sh" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "${DEST_DIR}/rustup.sh"
fi

# uv
if [ ! -f "${DEST_DIR}/uv_install.sh" ]; then
    wget https://astral.sh/uv/install.sh -O "${DEST_DIR}/uv_install.sh"
fi

