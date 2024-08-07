# we disable the `all` command because some external tool might run it automatically
.SUFFIXES:

all:

# runs all the test files.
test:
	nvim --version | head -n 1 && echo ''
	nvim --headless --noplugin -u ./scripts/minimal_init.lua \
		-c "lua require('mini.test').setup()" \
		-c "lua MiniTest.run({ execute = { reporter = MiniTest.gen_reporter.stdout({ group_depth = 1 }) } })"

# installs `mini.nvim`, used for both the tests and documentation.
deps:
	@mkdir -p deps
	git clone --depth 1 https://github.com/echasnovski/mini.nvim deps/mini.nvim
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim deps/plenary.nvim
	git clone --depth 1 https://github.com/nvim-telescope/telescope.nvim deps/telescope.nvim
	echo "#!/usr/bin/env bash\n\nmake precommit" > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit

# installs deps before running tests, useful for the CI.
test-ci: deps test

# generates the documentation.
documentation:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua require('mini.doc').generate()" -c "qa!"

# installs deps before running the documentation generation, useful for the CI.
documentation-ci: deps documentation

# performs a lint check and fixes issue if possible, following the config in `stylua.toml`.
lint:
	stylua .

# precommit
precommit:
	./scripts/precommit.sh

clean:
	rm -rf deps
