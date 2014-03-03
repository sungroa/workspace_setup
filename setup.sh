case $(uname -s) in
  Darwin)
    ./setup_mac.sh
    ;;
  Linux)
    ./setup_linux.sh
    ;;
  *)
    echo "Unsupported OS."
    false
    ;;
esac
