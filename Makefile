REPORTER = dot

all:
	@./node_modules/.bin/coffee --compile --output lib/ src/

test: 
	@NODE_ENV=test ./node_modules/.bin/mocha --recursive --reporter $(REPORTER) --ignore-leaks --compilers coffee:coffee-script

.PHONY: test all