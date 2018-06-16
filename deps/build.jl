using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libsuitesparseconfig"], :suitesparseconfig),
    LibraryProduct(prefix, String["libamd"], :amd),
    LibraryProduct(prefix, String["libbtf"], :btf),
    LibraryProduct(prefix, String["libcamd"], :camd),
    LibraryProduct(prefix, String["libccolamd"], :ccolamd),
    LibraryProduct(prefix, String["libcolamd"], :colamd),
    LibraryProduct(prefix, String["libcholmod"], :cholmod),
    LibraryProduct(prefix, String["libldl"], :ldl),
    LibraryProduct(prefix, String["libklu"], :klu),
    LibraryProduct(prefix, String["libumfpack"], :umfpack),
    LibraryProduct(prefix, String["librbio"], :rbio),
    LibraryProduct(prefix, String["libspqr"], :spqr),
    LibraryProduct(prefix, String["libsuitesparse_wrapper"], :suitesparse_wrapper),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaLinearAlgebra/SuiteSparseBuilder/releases/download/v5.2.0-0.2.20"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/SuiteSparse.aarch64-linux-gnu.tar.gz", "6155940af9d43d6888b660b519493fb4ab9ec3db21d3763cbbaa74b2111b9a32"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/SuiteSparse.arm-linux-gnueabihf.tar.gz", "92117b80dd9622d1c87a070a71e1dd71ef05b6e8aa8df0d5f727a2b8e67fa48e"),
    Linux(:i686, :glibc) => ("$bin_prefix/SuiteSparse.i686-linux-gnu.tar.gz", "384ed99c95fbc5580906a876af625a074363f9d9c3ff82224be33d63c8b4ad51"),
    Windows(:i686) => ("$bin_prefix/SuiteSparse.i686-w64-mingw32.tar.gz", "262218848d78ba6b7250004fe7ea53c2171fb8519cdc51e19066737dbb67de69"),
    MacOS(:x86_64) => ("$bin_prefix/SuiteSparse.x86_64-apple-darwin14.tar.gz", "64fdff152e51685f3b6d34d0484435e881861c6da08c260cc9c2c7466523b134"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/SuiteSparse.x86_64-linux-gnu.tar.gz", "4f0f958d11f8ca70ad9fb4e0b932ba662333a32c4069ee9d412d74b82ab126c7"),
    Windows(:x86_64) => ("$bin_prefix/SuiteSparse.x86_64-w64-mingw32.tar.gz", "1fc3f9884490b75ff87d661b70bd27935df97af0af697a25d78bcf97c5b28125"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)