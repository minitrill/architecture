/*
 Navicat Premium Data Transfer

 Source Server         : tencentcloud @ 182
 Source Server Type    : MySQL
 Source Server Version : 80011
 Source Host           : 118.126.104.182:3306
 Source Schema         : minitrill

 Target Server Type    : MySQL
 Target Server Version : 80011
 File Encoding         : 65001

 Date: 17/07/2018 20:22:36
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for BlackList
-- ----------------------------
DROP TABLE IF EXISTS `BlackList`;
CREATE TABLE `BlackList`  (
  `blacklist_id` int(11) NOT NULL COMMENT '用户黑名单日志',
  `uid` int(11) NULL DEFAULT NULL COMMENT '用户uid',
  `IP` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录IP',
  `equipment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录设备',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '城市',
  PRIMARY KEY (`blacklist_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Massage
-- ----------------------------
DROP TABLE IF EXISTS `Massage`;
CREATE TABLE `Massage`  (
  `massage_id` int(11) NOT NULL COMMENT '私信ID (自增,无需手动填写)',
  `status` tinyint(4) NULL DEFAULT 0 COMMENT '视频状态 (0-未审核, 1 - 正常,-1 - 非法(不展示))',
  `send_uid` bigint(20) NOT NULL COMMENT '发送者uid',
  `recive_uid` bigint(20) NOT NULL COMMENT '接收者uid',
  `text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '私信内容',
  `send_time` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '发送时间',
  PRIMARY KEY (`massage_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '私信默认不不设置审核字段,\r\n若内容安全发现私信违规则直接删除或修改私信内容.' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for SensitiveWords
-- ----------------------------
DROP TABLE IF EXISTS `SensitiveWords`;
CREATE TABLE `SensitiveWords`  (
  `sensitive_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `type` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '敏感词类型',
  `sensitive_words` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '敏感词列表 (以;分割)',
  `update_time` timestamp(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`sensitive_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for UserAudit
-- ----------------------------
DROP TABLE IF EXISTS `UserAudit`;
CREATE TABLE `UserAudit`  (
  `user_audit_id` int(11) NOT NULL COMMENT '用户审核数据id',
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `ban_type` char(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封禁类型 (色情,反动,违法...)',
  `evidence_type` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '证据类型ID (评论,私信,昵称)',
  `evidence_id` int(11) NULL DEFAULT NULL COMMENT '证据信息ID ',
  `record_time` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '封禁时间',
  PRIMARY KEY (`user_audit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of UserAudit
-- ----------------------------
INSERT INTO `UserAudit` VALUES (1, 1, NULL, NULL, NULL, '2018-07-15 18:39:26');

-- ----------------------------
-- Table structure for UserGroup
-- ----------------------------
DROP TABLE IF EXISTS `UserGroup`;
CREATE TABLE `UserGroup`  (
  `group_id` int(11) NOT NULL COMMENT '社群ID',
  `group_size` int(11) NULL DEFAULT NULL COMMENT '社群规模',
  `group_type` char(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '社群类型',
  `group_health` float(255, 0) NULL DEFAULT NULL COMMENT '社群健康度',
  `core_member` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '核心成员 (以;分割 uid)',
  `gen_time` datetime(0) NULL DEFAULT NULL COMMENT '社区记录生成时间',
  PRIMARY KEY (`group_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for UserRelation
-- ----------------------------
DROP TABLE IF EXISTS `UserRelation`;
CREATE TABLE `UserRelation`  (
  `relation_id` int(11) NOT NULL COMMENT '关系id (自增,无需手动填写)',
  `master_uid` bigint(20) NOT NULL COMMENT '被关注者UID',
  `fans_uid` bigint(20) NOT NULL COMMENT '关注者UID',
  `relation_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关系产生时间',
  PRIMARY KEY (`relation_id`) USING BTREE,
  INDEX `IND_master_id`(`master_uid`) USING BTREE,
  INDEX `IND_fans_id`(`fans_uid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '以1m用户为数量级预估,主要关系可能在10m这个数量级,因为此表非常小且无字符型变量,\r\n故直接整合为一表,剩去了分表中冗余的情况.主要是简单,(若后期性能出现问题则考虑用redis缓存大V数据)\r\n 此外,此表的一条记录 只表示, fans_id 主动关注了 master_id 关注关系只是单向的. ' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of UserRelation
-- ----------------------------
INSERT INTO `UserRelation` VALUES (1, 1, 2, '2018-07-15 17:57:41');

-- ----------------------------
-- Table structure for User_1
-- ----------------------------
DROP TABLE IF EXISTS `User_1`;
CREATE TABLE `User_1`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of User_1
-- ----------------------------
INSERT INTO `User_1` VALUES (1, 1, '`13', '/data/minitrill/user/photo/default/default.jpg', 'jerryhou', '123123', '保密', 18, '1995-07-05', '保密', '中国', '保密', '保密', '', 0, 0, 0, 0, '2018-07-15 15:06:29');
INSERT INTO `User_1` VALUES (2, 0, '3', '/data/minitrill/user/photo/default/default.jpg', '333', '2', '保密', 18, NULL, '保密', '中国', '保密', '保密', '', 0, 0, 0, 0, '2018-07-17 17:35:33');

-- ----------------------------
-- Table structure for User_10
-- ----------------------------
DROP TABLE IF EXISTS `User_10`;
CREATE TABLE `User_10`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for User_2
-- ----------------------------
DROP TABLE IF EXISTS `User_2`;
CREATE TABLE `User_2`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for User_3
-- ----------------------------
DROP TABLE IF EXISTS `User_3`;
CREATE TABLE `User_3`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for User_4
-- ----------------------------
DROP TABLE IF EXISTS `User_4`;
CREATE TABLE `User_4`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for User_5
-- ----------------------------
DROP TABLE IF EXISTS `User_5`;
CREATE TABLE `User_5`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for User_6
-- ----------------------------
DROP TABLE IF EXISTS `User_6`;
CREATE TABLE `User_6`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for User_7
-- ----------------------------
DROP TABLE IF EXISTS `User_7`;
CREATE TABLE `User_7`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for User_8
-- ----------------------------
DROP TABLE IF EXISTS `User_8`;
CREATE TABLE `User_8`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for User_9
-- ----------------------------
DROP TABLE IF EXISTS `User_9`;
CREATE TABLE `User_9`  (
  `uid` bigint(20) NOT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(255) NOT NULL DEFAULT 0 COMMENT '用户状态(0-未审核, 1 - 正常,-1 - 封禁)',
  `nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `photo_url` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '/data/minitrill/user/photo/default/default.jpg' COMMENT '头像路径',
  `account` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账号',
  `password` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码的hash值',
  `sex` enum('男','女','保密') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '性别',
  `age` tinyint(2) UNSIGNED NULL DEFAULT 18 COMMENT '年龄',
  `birth` date NULL DEFAULT NULL COMMENT '生日',
  `tel` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '电话',
  `country` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '中国' COMMENT '国家',
  `province` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '省份',
  `city` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '保密' COMMENT '城市',
  `brief_introduction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自我介绍',
  `follow` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '关注数',
  `fans` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数',
  `video_num` int(10) UNSIGNED NULL DEFAULT 0 COMMENT '作品数',
  `video_like_num` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '作品被赞数',
  `register_date` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `UNI_account`(`account`) USING BTREE COMMENT '账号唯一索引',
  INDEX `IND_nickname`(`nickname`) USING BTREE COMMENT '昵称索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关字段说明:\r\n\r\n关注数和粉丝数,视频数量不一定要实时更新,可以每一段时间根据其他表数据更新.\r\napi直接请求本表数据速度更快(类似缓存).' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for Video
-- ----------------------------
DROP TABLE IF EXISTS `Video`;
CREATE TABLE `Video`  (
  `vid` bigint(20) NOT NULL COMMENT '视频全局唯一ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '视频标题',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '视频状态 (0-未审核, 1 - 正常,-1 - 封禁)',
  `flag` tinyint(4) NOT NULL DEFAULT 0 COMMENT '视频处理标记 (0-未处理, 其他 后台,视频存储自行协商)',
  `uploader_uid` bigint(20) NOT NULL COMMENT '上传者全局唯一ID',
  `uploader_nickname` char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '上传者昵称',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '视频信息',
  `tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '视频标签 (多个标签用;分割,例如 : 游戏;英雄联盟;盲僧;王者)',
  `like` int(11) NOT NULL DEFAULT 0 COMMENT '点赞数',
  `share` int(11) NULL DEFAULT 0 COMMENT '分享数',
  `view` int(11) NULL DEFAULT 0 COMMENT '浏览量',
  `comment` int(11) NOT NULL DEFAULT 0 COMMENT '评论数',
  `upload_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '上传时间',
  `tag1_id` tinyint(4) NULL DEFAULT NULL COMMENT '标签1 id',
  `tag2_id` tinyint(4) NULL DEFAULT NULL COMMENT '标签2 id',
  `tag3_id` tinyint(4) NULL DEFAULT NULL COMMENT '标签3 id',
  `v_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '视频索引',
  `v_phtot_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '视频缩略图索引',
  PRIMARY KEY (`vid`) USING BTREE,
  UNIQUE INDEX `UNI_title`(`title`) USING BTREE COMMENT '视频标题唯一性索引',
  INDEX `IND_uploader_uid`(`uploader_uid`) USING BTREE COMMENT '视频上传者ID索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有关视频搜索:\r\n\r\n未添加视频搜索相关字段索引,因为视频搜索功能大多是是根据关键词的模糊搜索\r\nSQL 在执行 where v like \'%s...%s\' 的时候,不会使用索引,\r\n在MyISAM引擎中的全文索引虽然有类似功能但并使用场景非常有件. 故为对title字段设置任何索引\r\n\r\n解决思路:\r\n1. 通过like语句用MySQL全表扫描提供服务\r\n2. 通过推荐算法模块提供搜索服务\r\n3. 通过其他搜索工具与框架同步标题id等数据,提供服务' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of Video
-- ----------------------------
INSERT INTO `Video` VALUES (1, 'wtf', 0, 0, 1, '1', '', '', 0, 0, 0, 0, '2018-07-15 16:46:39', NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for VideoAudit
-- ----------------------------
DROP TABLE IF EXISTS `VideoAudit`;
CREATE TABLE `VideoAudit`  (
  `video_audit_id` int(11) NOT NULL COMMENT '视频审核ID',
  `vid` bigint(20) NULL DEFAULT NULL COMMENT '视频vid',
  `ban_type` char(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封禁类型',
  `evidence` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '封禁证据',
  `evidence_heath` float NULL DEFAULT NULL COMMENT '封禁证据健康度',
  `record_time` timestamp(0) NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`video_audit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for VideoComment
-- ----------------------------
DROP TABLE IF EXISTS `VideoComment`;
CREATE TABLE `VideoComment`  (
  `comment_id` int(11) NOT NULL COMMENT '评论记录id (自增,无需处理)',
  `vid` bigint(20) NULL DEFAULT NULL COMMENT '视频全局唯一ID',
  `uid` bigint(20) NULL DEFAULT NULL COMMENT '用户全局唯一ID',
  `status` tinyint(4) NULL DEFAULT NULL COMMENT '评论状态(0-未处理,1-正常,-1-禁止)',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评论内容',
  `ref_comment_id` int(11) NULL DEFAULT -1 COMMENT '本评论回复的评论id',
  `comment_like` int(11) NULL DEFAULT 0 COMMENT '评论喜欢数',
  `comment_time` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `IND_uid`(`uid`) USING BTREE,
  INDEX `IND_vid`(`vid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for VideoLike
-- ----------------------------
DROP TABLE IF EXISTS `VideoLike`;
CREATE TABLE `VideoLike`  (
  `like_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '点赞记录ID (自增,无需处理)',
  `uid` bigint(20) NOT NULL COMMENT '点赞用户UID',
  `vid` bigint(20) NOT NULL COMMENT '被点赞视频VID',
  `like_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`like_id`) USING BTREE,
  INDEX `IND_uid`(`uid`) USING BTREE,
  INDEX `IND_vid`(`vid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '额外创建点赞记录表主要用于:\r\n1. 记录点赞时间\r\n2. 分析点赞用户行为 (防水,用户特征)' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of VideoLike
-- ----------------------------
INSERT INTO `VideoLike` VALUES (1, 1, 1, '2018-07-15 17:36:38');

-- ----------------------------
-- Table structure for VideoTag
-- ----------------------------
DROP TABLE IF EXISTS `VideoTag`;
CREATE TABLE `VideoTag`  (
  `tag_id` int(11) NOT NULL COMMENT '标签id',
  `tag_name` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签名称',
  `tag_key_word` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签关键词 (TOP10)',
  `update_time` timestamp(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '标签更新时间',
  PRIMARY KEY (`tag_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
