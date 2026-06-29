package com.campus.lostfound.repository;

import com.campus.lostfound.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, String>, JpaSpecificationExecutor<User> {

    Optional<User> findByStudentIdAndDeleted(String studentId, Integer deleted);

    Optional<User> findByPhoneAndDeleted(String phone, Integer deleted);

    Optional<User> findByIdAndDeleted(String id, Integer deleted);

    boolean existsByStudentIdAndDeleted(String studentId, Integer deleted);

    boolean existsByPhoneAndDeleted(String phone, Integer deleted);
}
