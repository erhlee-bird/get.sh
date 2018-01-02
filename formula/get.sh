SRC=https://github.com/erhlee-bird/get.sh
. templates/git

build() {
  ln -fs "${TARGET}/get.sh" "${PREFIX}/bin"
}
