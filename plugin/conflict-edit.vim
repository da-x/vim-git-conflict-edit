function! EditConflictFiles()
    " These will be conflict files to edit
    let l:conflicts = []

    " Loop over each file in the arglist (passed in to vim from bash)
    for l:conflict in systemlist('git grep "^<<<<<<< "')
        let l:spl = split(l:conflict, ':')

        " If this line had a colon in it (otherwise it's an empty line
        " from command output)
        if len(l:spl) == 3
            let l:filename = l:spl[0]
            let l:line = l:spl[1]
            let l:text = l:spl[2]

            " Add this file to the list with the data format for the quickfix
            " window
            call add(l:conflicts, {'filename': l:filename, 'lnum': l:line, 'text': l:text})
        endif
    endfor

    " Set the quickfix files and open the list
    call setqflist(l:conflicts)
    execute 'copen'
    execute 'cfirst'
endfunction

" vim: set et sw=4 sts=4 ts=8:
