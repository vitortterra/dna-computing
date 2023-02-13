# DNA Computing Simulation

DNA computing is a massively parallel computation model in which the data is represented as DNA sequences and the processing consists of simultaneous realization of biological operations on these sequences. This model allows instances of NP-Hard problems to be solved in a polynomial number of steps. It was introduced by Leonard Adleman on his paper ["Molecular computation of solutions to combinatorial problems"](https://courses.cs.duke.edu/cps296.4/spring04/papers/Adleman94.pdf), in which he presents a solution to the [Hamiltonian path problem](https://en.wikipedia.org/wiki/Hamiltonian_path_problem).


This repo contains code that simulates DNA computing operations both sequentially and in parallel (in CUDA) and solves small instances of some NP-Hard problems (maximum independent set, minimum set cover and maximum clique).
