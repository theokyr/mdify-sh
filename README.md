# mdify.sh

## Description

`mdify.sh` is a Bash script to output files as markdown with their path structure. Ideal for sending large amounts of plaintext data to LLMs.

## Installation

```bash
git clone https://github.com/theokyr/mdify-sh.git
cd mdify.sh
chmod +x mdify.sh
```

## Usage

```bash
./mdify.sh <directory> <output_file> <extensions>
```

- `<directory>`: Root directory to search for files.
- `<output_file>`: File for markdown output.
- `<extensions>`: Comma-separated file extensions to include.

## Examples

Write the contents of all `.cpp` and `.java` files in `./src` to `output.md`:

```bash
./mdify.sh ./src output.md cpp,java
```

Contents of `output.md`:
```markdown
**`./main.cpp`:**
... file contents as a cpp code block ...

**`./src/java/com/domain/app/Application.java`:**
... file contents as a java code block ...

**`./src/java/com/domain/app/services/Service.java`:**
... file contents as a java code block ...
```

## Contribution

1. Fork the repo
2. Create a branch (`git checkout -b feature`)
3. Commit your changes (`git commit -m 'Add feature'`)
4. Push to the branch (`git push origin feature`)
5. Open a pull request

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contact

Open an issue for support.
