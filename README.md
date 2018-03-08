# uWSGI for Python debian packages
    
Builds `.deb` packages for uWSGI with Python 2.7 and the latest Python 3 from the [deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa). The [dogstatsd plugin](https://github.com/DataDog/uwsgi-dogstatsd) is included as well.

## Usage

```bash
docker build -t uwsgi-deb .
docker run --rm -it -v ~/.gnupg:/root/.gnupg uwsgi-deb
```

This will build and sign the necessary files and upload them to [the PPA](https://launchpad.net/~lincoln-loop/+archive/ubuntu/uwsgi).

## Releasing a new version

1. Update `UWSGI_VERSION` in the `Dockerfile`.
2. Add an entry to `debian/changelog` (`dch -i` is the easiest way to do this).


---

This is my first attempt and building Debian packages. If you see a problem, please submit an issue or pull request. 🙇
