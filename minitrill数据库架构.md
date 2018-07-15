minitrill 数据库架构设计
=================
2018 TEG 信息安全部 mini项目 数据库架构设计

### 一. 全局唯一ID
*全局唯一ID的获取及使用方法*

1. 数据库预估规模

| 数据类型 | 预估规模 |
| - | :-: |
| 用户信息量 | 1,000,000|
| 短视频数量 | 100,000 |
| 用户关系数 | 5,000,000 | 
| 视频评论数 | 1,000,000 | 

2. 全局唯一ID获取方法
因为项目整体基于Python开发,所以需要选取一个使用于Python的可移植的id生成器
> 选取了 **Liunx** 环境下 **Python 2.7+**  版本内建的 hash() 方法作为id生成器

数据库共两个全局ID (均为19位整数):
* 用户全局唯一ID - uid *(根据账号hash生成)*
* 视频全局唯一ID - vid *(根据视频名hash生成)*

使用hash()方法生成极为方便,例如 生成账号为 `h-j-13` 的uid代码如下:
```python
>>> hash('h-j-13')
1254600603083085472
```
可得, 账号`h-j-13`的 uid 为 **1254600603083085472**

注意:
由于Python在Windows和Linux平台下的解释器版本不同,所以在windows下执行可能会生成完成不一样的结果. **请务必在Linux下运行全局ID相关代码**


3. 全局唯一ID使用方法
为了性能及后期扩容的需要,现在将用户表**水平拆分**为用户表群(**共10张分表**),以uid为界限进行分割,获取用户全局ID对应的分表号的代码如下:
```python
def get_table_num(hash_value):
    """根据hash值获取分表号"""
    if -9223372036854775807 <= hash_value < -7393347003251626769:
        return 1
    elif -7393347003251626769 <= hash_value < -5544820905583124692:
        return 2
    elif -5544820905583124692 <= hash_value < -3703662328893783636:
        return 3
    elif -3703662328893783636 <= hash_value < -1864090509109668823:
        return 4
    elif -1864090509109668823 <= hash_value < -25556603170130521:
        return 5
    elif -25556603170130521 <= hash_value < 1829170723854020188:
        return 6
    elif 1829170723854020188 <= hash_value < 3671409183307186906:
        return 7
    elif 3671409183307186906 <= hash_value < 5513089284982408107:
        return 8
    elif 5513089284982408107 <= hash_value < 7373459306470554807:
        return 9
    elif 7373459306470554807 <= hash_value < 9233372036854775808:
        return 10
    else:   # 越界
        raise IndexError("Unexcept hash value")
```
*注意,只用用户表进行了分表,视频表未进行分表*


### 二. 数据库架构
*数据库架构的设计思想及说明*
数据库整体架构如图所示
![](https://upload-images.jianshu.io/upload_images/5617720-551c67722a9b4226.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

共分为4区:
* 后台基础区
* 社交关系区
* 内容安全区
* 推荐算法区

#### 后台基础区
1. 用户表群(这里一共十张用户表,以hash分割)

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| uid | bigint | PK | 用户全局唯一ID | 
| status | tinyint | NL | 用户状态(0-未审核, 1 - 正常,-1 - 封禁) | 
| nickname | char | NL | 昵称 | 
| photo_url | char | NL | 头像路径 | 
| account | char | NL | 账号 | 
| password | char | NL | 密码的hash值 | 
| sex | enum |   | 性别 | 
| age | char |   | 年龄 | 
| birth | char |   | 生日 | 
| tel | char |   | 电话 | 
| country | char |   | 国家 | 
| province | char |   | 省份 | 
| city | char |   | 城市 | 
| brief_introduction | varchar |   | 自我介绍 | 
| follow | int |   | 关注数 | 
| fans | int |   | 粉丝数 | 
| video_num | int |   | 作品数 | 
| register_date | timestamp | 自动生成  | 注册时间 | 

 
*有关字段说明*:
* 关注数和粉丝数,视频数量

此字段**不一定要实时更新**,可以每一段时间根据其他表数据更新.
api直接请求本表数据速度更快(类似缓存,用空间换时间).

* 头像路径
此字段默认值为
`'/data/minitrill/user/photo/default/default.jpg'`

推荐将头像字段按照如下的形式保存

├─data      
│  ├─minitrill      
│  │  ├─user        
│  │  │  ├─default          // 存放部分默认和可选头像       
│  │  │  ├─1                // 存放表1用户的头像, 以此类推      
│  │  │  ├─2        
...      
│  │  │  ├─10       

2. 视频表

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| vid | bigint | PK | 视频全局唯一ID | 
| title | varchar | NL | 视频标题 | 
| status | tinyint | NL | 视频状态 (0-未审核, 1 - 正常,-1 - 封禁) | 
| flag | tinyint | NL | 视频处理标记 (0-未处理, 其他 后台,视频存储自行协商 | 
| uploader_uid | bigint | NL | 上传者全局唯一ID | 
| uploader_nickname | char | NL | 上传者昵称 | 
| note | varchar | NL | 视频信息 | 
| tag | varchar | NL | 视频标签 (多个标签用;分割,例如 : 游戏;英雄联盟;盲僧;王者) | 
| like | int | NL-默认0 | 点赞数 | 
| comment | int | NL-默认0 | 评论数 | 
| upload_time | timestamp | 自动生成 | 上传时间 | 
| tag1_id | tinyint |   | 标签1 id | 
| tag2_id | tinyint |   | 标签2 id | 
| tag3_id | tinyint |   | 标签3 id | 
| v_url | varchar |   | 视频索引 | 
| v_phtot_url | varchar |   | 视频缩略图索引 | 

**有关视频搜索**:

未添加视频搜索相关字段索引,因为视频搜索功能大多是是根据关键词的模糊搜索
SQL 在执行 `where v like '%s...%s'` 的时候,**不会使用索引**,
在MyISAM引擎中的全文索引虽然有类似功能但并使用场景非常有件. 故为对title字段设置任何索引

*解决思路*:
*  通过like语句用MySQL全表扫描提供服务
* 通过推荐算法模块提供搜索服务
* 通过其他搜索工具与框架同步标题id等数据,提供服务


3. 视频标签表

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| tag_id | int | PK | 标签id | 
| tag_name | char |  | 标签名称 | 
| tag_key_word | varchar |  | 标签关键词 (TOP10) | 
| update_time | timestamp | 自动更新 | 标签更新时间 | 

#### 社交区

1. 用户关系表

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| relation_id | int | PK | 关系id (自增,无需手动填写) | 
| master_uid | bigint | IND | 被关注者UID | 
| fans_uid | bigint | IND | 关注者UID | 
| relation_time | timestamp | 自动生成 | 关系创建时间 | 

> 以1m用户为数量级预估,主要关系可能在10m这个数量级,因为此表非常小且无字符型变量,
> 故直接整合为一表,剩去了分表中冗余的情况.主要是简单,(若后期性能出现问题则考虑用redis缓存大V数据)
> 此外,此表的一条记录 只表示, fans_id 主动关注了 master_id 关注关系只是单向的. 

2. 私信表

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| massage_id | int | PK | 关系id (自增,无需手动填写) | 
| send_uid | bigint | IND | 发送者uid | 
| recive_uid | bigint | IND | 接收者uid | 
| text | varchar |  | 私信内容 | 
| send_time | timestamp | 自动生成 | 发送时间 | 

> 私信默认不不设置审核字段,
> 若内容安全发现私信违规则直接删除或修改私信内容.

3. 视频评论表

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| comment_id | int | PK | 评论记录id (自增,无需处理) | 
| vid | bigint | IND | 视频全局唯一ID | 
| uid | bigint | IND | 用户全局唯一ID | 
| status | varchar |  | 评论状态(0-未处理,1-正常,-1-禁止) | 
| comment | bigint | IND | 评论内容 | 
| comment_like | varchar |  | 评论喜欢数 | 
| comment_time | timestamp | 自动生成 | 评论时间 | 

4. 视频点赞表

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| like_id | int | PK | 点赞记录id (自增,无需处理) | 
| vid | bigint | IND | 视频全局唯一ID | 
| uid | bigint | IND | 用户全局唯一ID | 
| like_time | timestamp | 自动生成 | 点赞时间 | 

额外创建点赞记录表主要用于:
* 记录点赞时间
* 分析点赞用户行为 (防水,用户特征)

#### 内容安全区

1. 用户社群表
| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| group_id | int | PK | 社群ID | 
| group_size | int |  | 社群规模 | 
| group_type | char |  | 社群类型 | 
| group_health | float |  | 社群健康度 | 
| core_member | varchar |  | 核心成员 (以;分割 uid) | 
| gen_time | timestamp | 自动生成 | 社区记录生成时间 | 


2. 用户审核表

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| user_audit_id | int | PK | 用户审核数据ID | 
| uid | bigint |  | 用户全局唯一ID | 
| ban_type | char |  | 封禁类型 | 
| evidence_type | tinyint |  | 证据类型ID | 
| evidence_id | int |  | 证据信息ID  | 
| record_time | timestamp | 自动生成 | 封禁时间 | 

3. 视频审核表

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| video_audit_id | int | PK | 视频审核id | 
| vid | bigint |  | 视频vid | 
| ban_type | char |  | 封禁类型 | 
| evidence | text |  | 封禁证据(图片base64编码) | 
| evidence_heath | float |  | 封禁证据健康度  | 
| record_time | timestamp | 自动生成 | 封禁时间 | 

4. 敏感词表

| 字段名称 | 字段类型 | 字段索引/其他 | 备注 |
| - | :-: | :-: | :-: |
| sensitive_id | int | PK | 记录ID | 
| type | char |  | 敏感词类型 | 
| sensitive_words | varchar |  | 敏感词列表 (以;分割) | 
| update_time | timestamp |  | 更新时间 | 

> 主要配合前段屏蔽使用


#### 推荐算法区
由推荐算法组自行生成,主要为视频特征表和用户特征表


### 三. 配置调优
*基于MySQL5.7 的数据库配置调优*
考虑到服务器上其他的业务及程序需求,将InnoDB的 **缓存大小设置为20G左右**.
其他详细设置参考 `my.cnf` 配置文件


```
# my.cnf配置文件
# 生产环境下mysql配置优化 (72G内存)
# @author   :   h-j-13
# @time     :   2018-01-17


[mysqld]
# ------------主要配置-----------------
# 端口
port = 36666

# 数据地址
datadir=/home/DATA/mysql

socket=/home/DATA/mysql/mysql.sock

tmpdir=/home/DATA/tmp


# 用户
user=mysql

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

# 字符编码
character_set_server = utf8

# 表名大小写敏感
lower_case_table_names = 0

open_files_limit = 10240
# inux下设置最大文件打开数
# open_files_limit最后取值为 配置文件 open_files_limit，max_connections*5， wanted_files= 10+max_connections+table_cache_size*2 三者中的最大值。

binlog_cache_size = 4M
# 1~2M
# 如果有很大的事务,可以适当增加这个缓存值,以获取更好的性能

back_log = 600  
# 默认值 80
# 在MYSQL暂时停止响应新请求之前，短时间内的多少个请求可以被存在堆栈中。如果系统在短时间内有很多连接，
# 则需要增大该参数的值，该参数值指定到来的TCP/IP连接的监听队列的大小。

max_connections = 1024  
# 默认值 151
# MySQL允许最大的进程连接数，如果经常出现Too Many Connections的错误提示，则需要增大此值。

max_connect_errors = 4000  
# 默认值 100
# 设置每个主机的连接请求异常中断的最大次数
# 当超过该次数，MYSQL服务器将禁止host的连接请求，直到mysql服务器重启或通过flush hosts命令清空此host的相关信息。

external-locking = FALSE  
# 使用–skip-external-locking MySQL选项以避免外部锁定。该选项默认开启

max_allowed_packet = 1024M
# 2018-2-14 从32m调整到1024m 
# 默认值 4MB
# 设置在网络传输中一次消息传输量的最大值。系统默认值 为4MB，最大值是1GB，必须设置1024的倍数。


# 尝试解决 2006问题
wait_timeout=288000
interactive_timeout = 288000

sort_buffer_size = 2M  
# Sort_Buffer_Size 是一个connection级参数，在每个connection（session）第一次需要使用这个buffer的时候，一次性分配设置的内存。
# Sort_Buffer_Size 并不是越大越好，由于是connection级的参数，过大的设置+高并发可能会耗尽系统内存资源。例如：500个连接将会消耗 500*sort_buffer_size(8M)=4G内存
# Sort_Buffer_Size 超过2KB的时候，就会使用mmap() 而不是 malloc() 来进行内存分配，导致效率降低。 系统默认2M，使用默认值即可

join_buffer_size = 2M  
# 默认 128K
# 用于表间关联缓存的大小，和sort_buffer_size一样，该参数对应的分配内存也是每个连接独享。系统默认2M，使用默认值即可

thread_cache_size = 300  
# 默认 38
# 服务器线程缓存这个值表示可以重新利用保存在缓存中线程的数量,当断开连接时如果缓存中还有空间,
# 那么客户端的线程将被放到缓存中,如果线程重新被请求，那么请求将从缓存中读取,如果缓存中是空的或者是新的请求，
# 那么这个线程将被重新创建,如果有很多新的线程，增加这个值可以改善系统性能.通过比较 Connections 和 Threads_created 状态的变量，可以看到这个变量的作用。
# 设置规则如下：1GB 内存配置为8，2GB配置为16，3GB配置为32，4GB或更高内存，可配置更大。

# thread_concurrency = 8  
# 系统默认为10，使用10先观察
# 设置thread_concurrency的值的正确与否, 对mysql的性能影响很大, 在多个cpu(或多核)的情况下，错误设置了thread_concurrency的值, 会导致mysql不能充分利用多cpu(或多核), 
# 出现同一时刻只能一个cpu(或核)在工作的情况。thread_concurrency应设为CPU核数的2倍. 比如有一个双核的CPU, 那么thread_concurrency的应该为4; 
# 2个双核的cpu, thread_concurrency的值应为8
# 殊不知，thread_concurrency是在特定场合下才能使用的，参考mysql手册 ：
# 这个变量是针对Solaris系统的，如果设置这个变量的话，mysqld就会调用thr_setconcurrency()。这个函数使应用程序给同一时间运行的线程系统提供期望的线程数目。
# 另外需要说明的是：这个参数到5.6版本就去掉了

query_cache_size = 64M  
# 在MyISAM引擎优化中，这个参数也是一个重要的优化参数。但也爆露出来一些问题。机器的内存越来越大，
# 习惯性把参数分配的值越来越大。这个参数加大后也引发了一系列问题。我们首先分析一下 query_cache_size的工作原理：
# 一个SELECT查询在DB中工作后，DB会把该语句缓存下来，当同样的一个SQL再次来到DB里调用时，DB在该表没发生变化的情况下把结果从缓存中返回给Client。
# 这里有一个关建点，就是DB在利用Query_cache工作时，要求该语句涉及的表在这段时间内没有发生变更。那如果该表在发生变更时，Query_cache里的数据又怎么处理呢？
# 首先要把Query_cache和该表相关的语句全部置为失效，然后在写入更新。那么如果Query_cache非常大，该表的查询结构又比较多，查询语句失效也慢，
# 一个更新或是Insert就会很慢，这样看到的就是Update或是Insert怎么这么慢了。
# 所以在数据库写入量或是更新量也比较大的系统，该参数不适合分配过大。而且在高并发，写入量大的系统，建议把该功能禁掉。

query_cache_limit = 4M  
# 指定单个查询能够使用的缓冲区大小，缺省为1M

query_cache_min_res_unit = 4k  
# 默认是4KB，设置值大对大数据查询有好处，但如果你的查询都是小数据查询，就容易造成内存碎片和浪费
# 查询缓存碎片率 = Qcache_free_blocks / Qcache_total_blocks * 100%
# 如果查询缓存碎片率超过20%，可以用FLUSH QUERY CACHE整理缓存碎片，或者试试减小query_cache_min_res_unit，如果你的查询都是小数据量的话。
# 查询缓存利用率 = (query_cache_size – Qcache_free_memory) / query_cache_size * 100%
# 查询缓存利用率在25%以下的话说明query_cache_size设置的过大，可适当减小;
# 查询缓存利用率在80%以上而且Qcache_lowmem_prunes > 50的话说明query_cache_size可能有点小，要不就是碎片太多。
# 查询缓存命中率 = (Qcache_hits – Qcache_inserts) / Qcache_hits * 100%

default-storage-engine = INNODB
# default_table_type = InnoDB 
# 开启失败

thread_stack = 256K
# 默认 32bit - 192K 
# 64bit - 256K
# 设置MYSQL每个线程的堆栈大小，默认值足够大，可满足普通操作。可设置范围为128K至4GB，默认为256KB，使用默认观察

transaction_isolation = READ-COMMITTED  
# 设定默认的事务隔离级别.可用的级别如下:READ UNCOMMITTED-读未提交 READ COMMITTE-读已提交 REPEATABLE READ -可重复读 SERIALIZABLE -串行

tmp_table_size = 256M  
# tmp_table_size 的默认大小是 32M。如果一张临时表超出该大小，MySQL产生一个 The table tbl_name is full 形式的错误，如果你做很多高级 GROUP BY 查询，增加 tmp_table_size 值。如果超过该值，则会将临时表写入磁盘。

max_heap_table_size = 256M

expire_logs_days = 7  

key_buffer_size = 2048M  
# 批定用于索引的缓冲区大小，增加它可以得到更好的索引处理性能，对于内存在4GB左右的服务器来说，该参数可设置为256MB或384MB。

read_buffer_size = 1M  
# 默认128K
# 128K~256K
# MySql读入缓冲区大小。对表进行顺序扫描的请求将分配一个读入缓冲区，MySql会为它分配一段内存缓冲区。
# read_buffer_size变量控制这一缓冲区的大小。如果对表的顺序扫描请求非常频繁，并且你认为频繁扫描进行得太慢，
# 可以通过增加该变量值以及内存缓冲区大小提高其性能。和sort_buffer_size一样，
# 该参数对应的分配内存也是每个连接独享。

read_rnd_buffer_size = 16M  
# 128K~256K
# MySql的随机读（查询操作）缓冲区大小。当按任意顺序读取行时(例如，按照排序顺序)，将分配一个随机读缓存区。
# 进行排序查询时，MySql会首先扫描一遍该缓冲，以避免磁盘搜索，提高查询速度，如果需要排序大量数据，可适当调高该值。
# 但MySql会为每个客户连接发放该缓冲空间，所以应尽量适当设置该值，以避免内存开销过大。

bulk_insert_buffer_size = 64M  
# 批量插入数据缓存大小，可以有效提高插入效率，默认为8M

myisam_sort_buffer_size = 128M  
# MyISAM表发生变化时重新排序所需的缓冲 默认8M

myisam_max_sort_file_size = 10G  
# MySQL重建索引时所允许的最大临时文件的大小 (当 REPAIR, ALTER TABLE 或者 LOAD DATA INFILE).
# 如果文件大小比此值更大,索引会通过键值缓冲创建(更慢)

# myisam_max_extra_sort_file_size = 10G 5.6无此值设置
# myisam_repair_threads = 1   默认为1
# 如果一个表拥有超过一个索引, MyISAM 可以通过并行排序使用超过一个线程去修复他们.
# 这对于拥有多个CPU以及大量内存情况的用户,是一个很好的选择.

myisam_recover  
# 自动检查和修复没有适当关闭的 MyISAM 表
skip-name-resolve  

server-id = 1

# innodb_additional_mem_pool_size = 16M  
# 这个参数用来设置 InnoDB 存储的数据目录信息和其它内部数据结构的内存池大小，类似于Oracle的library cache。这不是一个强制参数，可以被突破。
# 5.6不赞成使用,一个将被废除的设置
# InnoDB: Warning: Using innodb_additional_mem_pool_size is DEPRECATED. This option may be removed in future releases

innodb_buffer_pool_size = 50G
# 这对Innodb表来说非常重要。Innodb相比MyISAM表对缓冲更为敏感。
# MyISAM可以在默认的 key_buffer_size 设置下运行的可以，然而Innodb在默认的 innodb_buffer_pool_size 设置下却跟蜗牛似的。
# 由于Innodb把数据和索引都缓存起来，无需留给操作系统太多的内存，因此如果只需要用Innodb的话则可以设置它高达 70-80% 的可用内存。
# 一些应用于 key_buffer 的规则有 — 如果你的数据量不大，并且不会暴增，那么无需把 innodb_buffer_pool_size 设置的太大了

innodb_buffer_pool_instances = 8
# innodb_buffer_pool_instances可以开启多个内存缓冲池，把需要缓冲的数据hash到不同的缓冲池中，这样可以并行的内存读写。
# innodb_buffer_pool_instances 参数显著的影响测试结果，特别是非常高的 I/O 负载时。
# 实验环境下， innodb_buffer_pool_instances=8 在很小的 buffer_pool 大小时有很大的不同，而使用大的 buffer_pool 时，innodb_buffer_pool_instances=1 的表现最棒。

# innodb_data_file_path = ibdata1:2G:autoextend 
# 设置过大导致报错，默认12M观察
# 表空间文件 重要数据

# innodb_file_io_threads = 4   
# 默认值 4
# 文件IO的线程数，一般为 4，但是在 Windows 下，可以设置得较大。

# innodb_thread_concurrency = 0  
# 服务器有几个CPU就设置为几，建议用默认设置，一般为8.

innodb_flush_log_at_trx_commit = 2  
# 如果将此参数设置为1，将在每次提交事务后将日志写入磁盘。为提供性能，
# 可以设置为0或2，但要承担在发生故障时丢失数据的风险。设置为0表示事务日志写入日志文件，而日志文件每秒刷新到磁盘一次。
# 设置为2表示事务日志将在提交时写入日志，但日志文件每次刷新到磁盘一次。

innodb_log_buffer_size = 64M   
# 使用默认8M
# 此参数确定些日志文件所用的内存大小，以M为单位。
# 缓冲区更大能提高性能，但意外的故障将会丢失数据.MySQL开发人员建议设置为1－8M之间

innodb_log_file_size = 1024M  
# 使用默认48M
# 此参数确定数据日志文件的大小，以M为单位，更大的设置可以提高性能，但也会增加恢复故障数据库所需的时间

innodb_log_files_in_group = 3   
# 使用默认2
# 为提高性能，MySQL可以以循环方式将日志文件写到多个文件。推荐设置为3M

innodb_max_dirty_pages_pct = 90  
# 默认 75
# 推荐阅读 http://www.taobaodba.com/html/221_innodb_max_dirty_pages_pct_checkpoint.html
# Buffer_Pool中Dirty_Page所占的数量，直接影响InnoDB的关闭时间。参数innodb_max_dirty_pages_pct 
# 可以直接控制了Dirty_Page在Buffer_Pool中所占的比率，而且幸运的是innodb_max_dirty_pages_pct是可以动态改变的。
# 所以，在关闭InnoDB之前先将innodb_max_dirty_pages_pct调小，强制数据块Flush一段时间，则能够大大缩短 MySQL关闭的时间。

innodb_lock_wait_timeout = 120  
# 默认为50秒 
# InnoDB 有其内置的死锁检测机制，能导致未完成的事务回滚。但是，如果结合InnoDB使用MyISAM的lock tables 语句或第三方事务引擎,则InnoDB无法识别死锁。
# 为消除这种可能性，可以将innodb_lock_wait_timeout设置为一个整数值，指示 MySQL在允许其他事务修改那些最终受事务回滚的数据之前要等待多长时间(秒数)

innodb_file_per_table = 0  
# 默认为No
# 独享表空间（关闭）


 
[mysqld_safe]
# -----------安全性配置-----------------
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
# sql_mode 详见 https://segmentfault.com/a/1190000005936172
# sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES  

[client]
# ------------客户端配置----------------
socket = /home/DATA/mysql/mysql.sock
#datadir=/home/DATA/mysql


[mysql]
# ------------启动配置------------------
#这个配置段设置启动MySQL服务的条件；在这种情况下，no-auto-rehash确保这个服务启动得比较快。
no-auto-rehash


[mysqldump]
# ------------备份设置------------------
quick  
max_allowed_packet = 128M
```

#### Author
h-j-13
2018-07-15 