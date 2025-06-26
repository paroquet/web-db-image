package org.example.webdbimage

import org.springframework.stereotype.Service

@Service
class UserService(private val repo: UserRepository) {
    fun findAll(): List<User> = repo.findAll()
    fun save(user: User): User = repo.save(user)
}