# code reflection entry-points

# TODO: get and disassemble the native binary using oneL0

#
# code_* replacements
#

# function to split off certain kwargs for selective forwarding, at run time.
# `@oneapi` does something similar at parse time, using `GPUCompiler.split_kwargs`.
function split_kwargs_runtime(kwargs, wanted::Vector{Symbol})
    remaining = Dict{Symbol, Any}()
    extracted = Dict{Symbol, Any}()
    for (key, value) in kwargs
        if key in wanted
            extracted[key] = value
        else
            remaining[key] = value
        end
    end
    return extracted, remaining
end

for method in (:code_typed, :code_warntype, :code_llvm, :code_native)
    # only code_typed doesn't take a io argument
    args = method == :code_typed ? (:job,) : (:io, :job)

    @eval begin
        function $method(io::IO, @nospecialize(func), @nospecialize(types);
                         kernel::Bool=false, kwargs...)
            compiler_kwargs, kwargs = split_kwargs_runtime(kwargs, COMPILER_KWARGS)
            source = FunctionSpec(typeof(func), Base.to_tuple_type(types))
            config = compiler_config(device(); kernel, compiler_kwargs...)
            job = CompilerJob(source, config)
            GPUCompiler.$method($(args...); kwargs...)
        end
        $method(@nospecialize(func), @nospecialize(types); kwargs...) =
            $method(stdout, func, types; kwargs...)
    end
end

const code_spirv = code_native



#
# @device_code_* functions
#

export @device_code_lowered, @device_code_typed, @device_code_warntype,
       @device_code_llvm, @device_code_spirv,
       @device_code

@eval $(Symbol("@device_code_lowered")) = $(getfield(GPUCompiler, Symbol("@device_code_lowered")))
@eval $(Symbol("@device_code_typed")) = $(getfield(GPUCompiler, Symbol("@device_code_typed")))
@eval $(Symbol("@device_code_warntype")) = $(getfield(GPUCompiler, Symbol("@device_code_warntype")))
@eval $(Symbol("@device_code_llvm")) = $(getfield(GPUCompiler, Symbol("@device_code_llvm")))
@eval $(Symbol("@device_code_spirv")) = $(getfield(GPUCompiler, Symbol("@device_code_native")))
@eval $(Symbol("@device_code")) = $(getfield(GPUCompiler, Symbol("@device_code")))
