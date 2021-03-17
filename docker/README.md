Ref: [IDF Docker Image](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/tools/idf-docker-image.html)

```bash
docker build --platform linux/amd64 -t azrtos-esp-idf .
```

## Usage

### Building a project with CMake

```bash
docker run --rm -v $PWD:/project -w /project azrtos-esp-idf idf.py build
```

### Using the image interactively

```bash
docker run --platform linux/amd64 --rm -v $PWD:/project -w /project -it azrtos-esp-idf
```

### Using the image interactively with default Bash

```bash
docker run --platform linux/amd64 --rm -it --entrypoint /bin/bash azrtos-esp-idf
```