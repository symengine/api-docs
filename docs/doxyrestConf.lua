-- Travis conditional
testTravis = os.getenv("TRAVIS_BUILD_DIR")
if (testTravis == nil)
then
  addDir = "./"
else
  addDir = testTravis
end

-- Specify input and output paths:

OUTPUT_FILE = addDir .. "docs/Sphinx/gen_doxyrest/index.rst"
INPUT_FILE = addDir .. "docs/Doxygen/gen_docs/xml/index.xml"
FRAME_FILE = addDir .. "docs/doxyrest/frame/cfamily/index.rst.in"
FRAME_DIR_LIST = {  addDir .. "docs/doxyrest/frame/cfamily",  addDir .."docs/doxyrest/frame/common" }

print(INPUT_FILE)
print(OUTPUT_FILE)
print(FRAME_DIR_LIST[1])
print(FRAME_DIR_LIST[2])

-- Usually, Doxygen-based documentation has a main page (created with
-- the \mainpage directive). If that's the case, force-include
-- the contents of 'page_index.rst' into 'index.rst':

INTRO_FILE = "page_index.rst"

-- If your documentation uses \verbatim directives for code snippets
-- you can convert those to reStructuredText C++ code-blocks:

VERBATIM_TO_CODE_BLOCK = "cpp"

-- Asterisks, pipes and trailing underscores have special meaning in
-- reStructuredText. If they appear in Doxy-comments anywhere except
-- for code-blocks, they must be escaped:

ESCAPE_ASTERISKS = true
ESCAPE_PIPES = true
ESCAPE_TRAILING_UNDERSCORES = true
