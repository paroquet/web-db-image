package org.example.webdbimage

import org.springframework.data.jpa.repository.JpaRepository

interface UserRepository : JpaRepository<User, Long>