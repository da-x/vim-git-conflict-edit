function! EditConflictFiles()
    let l:conflicted = systemlist('git diff --name-only --diff-filter=U')
    let l:messaged = []

    for l:conflict in l:conflicted
        let tmp = substitute(l:conflict, '\_s\+', '', 'g')
        if len(tmp) > 0
            call add(l:messaged, tmp)
        endif
    endfor

    call s:ProcessConflictFiles(l:messaged)
endfunction

" Experimental function to load vim with all l:conflicted files
function! s:ProcessConflictFiles(files)
    " These will be conflict files to edit
    let l:conflicts = []

    " Read git attributes file into a string
    if filereadable(expand('.gitattributes'))
        let l:gitignore = join(readfile('.gitattributes'), '')
    else
        let l:gitignore = ''
    endif

    let l:conflict_files = len(a:files) ? a:files : argv()

    " Loop over each file in the arglist (passed in to vim from bash)
    for l:conflict in l:conflict_files

        " If this file is not ignored in gitattributes (this could be improved)
        if l:gitignore !~ l:conflict

            " Grep each file for the starting error marker
            let markers = systemlist("grep -n '<<<<<<<' ".l:conflict)

            for marker in markers
                let l:spl = split(marker, ':')

                " If this line had a colon in it (otherwise it's an empty line
                " from command output)
                if len(l:spl) == 2

                    " Get the line number by removing the white space around it,
                    " because vim is a piece of shit
                    let l:line = substitute(l:spl[0], '\_s\+', '', 'g')

                    " Add this file to the list with the data format for the quickfix
                    " window
                    call add(l:conflicts, {'filename': 
                                \ l:conflict, 'lnum': l:line, 'text': l:spl[1]})
                endif
            endfor
        endif
    endfor

    " Set the quickfix files and open the list
    call setqflist(l:conflicts)
    execute 'copen'
    execute 'cfirst'
endfunction

" vim: set et sw=4 sts=4 ts=8:
