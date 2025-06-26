package org.example.webdbimage

import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/users")
class UserController(private val service: UserService) {

    @GetMapping
    fun getAll(): List<User> = service.findAll()

    @PostMapping
    fun create(@RequestBody user: User): User = service.save(user)
}