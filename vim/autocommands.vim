" File: autocommands.vim
" Author: Icko Iben
" Date Created: idk man
" Date Last Modified: 12 Oct 2023
" 
" File for autocommands in vim. These autocommands include opening template
" files and defining user commands.

" Templates
" =========

" newgitignore
" Creates a `.gitignore` file from template
" Usage: `vim newgitignore` from command line
autocmd BufNewFile newgitignore 0r ~/.vim/templates/gitignore.template

" newtodo
" Creates a `TODO.md` file from template
" Usage: `vim newtodo` from command line
autocmd BufNewFile newtodo 0r ~/.vim/templates/TODO.template

" new template for baylor csi projects
" includes pre-file comments and pre-function comments
" Usage: `vim newbaylorcsi` from command line
autocmd BufNewFile newbaylorcsi 0r ~/.vim/templates/baylorcsi.template

" cpp Makefile
" Usage: `vim newcppmake`
autocmd BufNewFile newcppmake 0r ~/.vim/templates/Makefile.cpp.template

" pandoc Makefile
" Usage: `vim newpandocmake`
autocmd BufNewFile newpandocmake 0r ~/.vim/templates/Makefile.pandoc.template

" Autocommands
" ============

" Markdown Live Previewer Helper (depreciated version)
" Vim autocommand to touch /tmp/bufwrite upon saving a Markdown file
" This triggers the onmodify function (when used) to perform its actions
" au BufWritePost *.md !touch /tmp/bufwrite

" Markdown Live Preview Helper
" Vim autocommand to pandoc current file upon write if the current file is .md
"augroup PandocMarkdown
"    autocmd!
"    autocmd BufWritePost *.md !pandoc % --pdf-engine=xelatex -H ~/.dotfiles-and-scripts/latex/preambles/math.tex --highlight-style=breezedark -o %<.pdf
"augroup END

" Only activate PandocMarkdown on startup if set in .vimrc
"if g:enable_pandoc_markdown
"    augroup PandocMarkdown
"        autocmd!
"        " The autocmd is listed here, but it's not active by default.
"    augroup END
"endif

" Always define the PandocMarkdown augroup
augroup PandocMarkdown
    autocmd!
    if g:enable_pandoc_markdown
        " The autocmd is listed here, but it's only added if the variable is set.
        autocmd BufWritePost *.md !pandoc % --pdf-engine=xelatex -H ~/.dotfiles-and-scripts/latex/preambles/math.tex --highlight-style=breezedark -o %<.pdf
    endif
augroup END

" Command to enable the PandocMarkdown autocommands
command! EnablePandoc autocmd! PandocMarkdown | autocmd PandocMarkdown BufWritePost *.md !pandoc % --pdf-engine=xelatex -H ~/.dotfiles-and-scripts/latex/preambles/math.tex --highlight-style=breezedark -o %<.pdf

" Command to disable the PandocMarkdown autocommands
command! DisablePandoc autocmd! PandocMarkdown

" Function and command to toggle the PandocMarkdown autocommands
function! TogglePandoc()
    if exists("#PandocMarkdown#BufWritePost")
        " The autocmd exists, so we remove it
        autocmd! PandocMarkdown BufWritePost *.md
    else
        " The autocmd doesn't exist, so we add it
        autocmd PandocMarkdown BufWritePost *.md !pandoc % --pdf-engine=xelatex -H ~/.dotfiles-and-scripts/latex/preambles/math.tex --highlight-style=breezedark -o %<.pdf
    endif
endfunction

" Command to toggle PandocMarkdown autocommand
command! TogglePandoc call TogglePandoc()

" Shortcuts
command! EP EnablePandoc
command! DP DisablePandoc
command! TP call TogglePandoc()
