const orig_stdin  = Ref{IO}()
const orig_stdout = Ref{IO}()
const orig_stderr = Ref{IO}()

# the following constants need to be initialized in init().
const read_stdout = Ref{Base.PipeEndpoint}()
const read_stderr = Ref{Base.PipeEndpoint}()
