using oneAPI, Test


drv = driver()
sycl_platform = SYCL.syclMakePlatform(drv)

dev = device()
sycl_device = SYCL.syclMakeDevice(sycl_platform, dev)

ctx = context()
sycl_context = SYCL.syclMakeContext([sycl_device], ctx)

queue = global_queue(ctx, dev)
sycl_queue = SYCL.syclMakeQueue(sycl_context, queue)


A = oneArray(rand(Float32, 2, 3))

B = oneArray(rand(Float32, 3, 4))

C = oneAPI.zeros(Float32, size(A, 1), size(B, 2))

oneMKL.oneapiSgemm(sycl_queue, oneMKL.nontrans, oneMKL.nontrans,
                   size(A, 1), size(B, 2), size(A, 2),
                   1f0,
                   A, stride(A, 2),
                   B, stride(B, 2),
                   0f0,
                   C, stride(C, 2))

@test Array(C) ≈ Array(A) * Array(B)

println("Done")
