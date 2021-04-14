//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/9/21.
//

import Foundation
import libmdbx_ios

struct MDBXEnvironmentFlags: OptionSet {
  let rawValue: UInt32
  
  /**
   - Tag: MDBXEnvironmentFlags.envDefauls
   */
  static let envDefaults = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_ENV_DEFAULTS.rawValue)
  /**
   No environment directory.
   
   By default, MDBX creates its environment in a directory whose pathname is
   given in path, and creates its data and lock files under that directory.
   With this option, path is used as-is for the database main data file.
   The database lock file is the path with "-lck" appended.
   
   - with [noSubDir](x-source-tag://[MDBXEnvironmentFlags.noSubDir]), = in a filesystem we have the pair of MDBX-files
   which names derived from given pathname by appending predefined suffixes.
   
   - without [noSubDir](x-source-tag://[MDBXEnvironmentFlags.noSubDir]) = in a filesystem we have the MDBX-directory with
   given pathname, within that a pair of MDBX-files with predefined names.
   
   This flag affects only at new environment creating by \ref mdbx_env_open(),
   otherwise at opening an existing environment libmdbx will choice this
   automatically.
   - Tag: MDBXEnvironmentFlags.noSubDir
   */
  static let noSubDir = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_NOSUBDIR.rawValue)
  
  /**
   Read only mode.
   
   Open the environment in read-only mode. No write operations will be
   allowed. MDBX will still modify the lock file - except on read-only
   filesystems, where MDBX does not use locks.
   
   - with [readOnly](x-source-tag://[MDBXEnvironmentFlags.readOnly]) = open environment in read-only mode.
   MDBX supports pure read-only mode (i.e. without opening LCK-file) only
   when environment directory and/or both files are not writable (and the
   LCK-file may be missing). In such case allowing file(s) to be placed
   on a network read-only share.
   
   - without [readOnly](x-source-tag://[MDBXEnvironmentFlags.readOnly]) = open environment in read-write mode.
   
   This flag affects only at environment opening but can't be changed after.
   - Tag: MDBXEnvironmentFlags.readOnly
   */
  static let readOnly = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_RDONLY.rawValue)
  
  /**
   Open environment in exclusive/monopolistic mode.
   
   [exclusive](x-source-tag://[MDBXEnvironmentFlags.exclusive]) flag can be used as a replacement for `MDB_NOLOCK`,
   which don't supported by MDBX.
   In this way, you can get the minimal overhead, but with the correct
   multi-process and multi-thread locking.
   
   - with [exclusive](x-source-tag://[MDBXEnvironmentFlags.exclusive]) = open environment in exclusive/monopolistic mode
   or return \ref MDBX_BUSY if environment already used by other process.
   The main feature of the exclusive mode is the ability to open the
   environment placed on a network share.
   
   - without [exclusive](x-source-tag://[MDBXEnvironmentFlags.exclusive]) = open environment in cooperative mode,
   i.e. for multi-process access/interaction/cooperation.
   The main requirements of the cooperative mode are:
   
     1. data files MUST be placed in the LOCAL file system,
       but NOT on a network share.
     2. environment MUST be opened only by LOCAL processes,
       but NOT over a network.
     3. OS kernel (i.e. file system and memory mapping implementation) and
       all processes that open the given environment MUST be running
       in the physically single RAM with cache-coherency. The only
       exception for cache-consistency requirement is Linux on MIPS
       architecture, but this case has not been tested for a long time).
   
   This flag affects only at environment opening but can't be changed after.
   - Tag: MDBXEnvironmentFlags.exclusive
   */
  static let exclusive = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_EXCLUSIVE.rawValue)
  
  /**
   Using database/environment which already opened by another process(es).
   
   The [accede](x-source-tag://[MDBXEnvironmentFlags.accede]) flag is useful to avoid \ref MDBX_INCOMPATIBLE error
   while opening the database/environment which is already used by another
   process(es) with unknown mode/flags. In such cases, if there is a
   difference in the specified flags ([noMetaSync](x-source-tag://[MDBXEnvironmentFlags.noMetaSync]),
   [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]),
   [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync]),
   [lifoReclaim](x-source-tag://[MDBXEnvironmentFlags.lifoReclaim]),
   [coalesce](x-source-tag://[MDBXEnvironmentFlags.coalesce]) and
   [noReadAhead](x-source-tag://[MDBXEnvironmentFlags.noReadAhead])), instead of returning an error,
   the database will be opened in a compatibility with the already used mode.
   
   [accede](x-source-tag://[MDBXEnvironmentFlags.accede]) has no effect if the current process is the only one either
   opening the DB in read-only mode or other process(es) uses the DB in
   read-only mode.
   - Tag: MDBXEnvironmentFlags.accede
   */
  static let accede = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_ACCEDE.rawValue)
  
  /**
   Map data into memory with write permission.
   
   Use a writeable memory map unless [readOnly](x-source-tag://[MDBXEnvironmentFlags.readOnly]) is set. This uses fewer
   mallocs and requires much less work for tracking database pages, but
   loses protection from application bugs like wild pointer writes and other
   bad updates into the database. This may be slightly faster for DBs that
   fit entirely in RAM, but is slower for DBs larger than RAM. Also adds the
   possibility for stray application writes thru pointers to silently
   corrupt the database.
   
   - with [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap]) = all data will be mapped into memory in the
   read-write mode. This offers a significant performance benefit, since the
   data will be modified directly in mapped memory and then flushed to disk
   by single system call, without any memory management nor copying.
   
   - without [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap]) = data will be mapped into memory in the
   read-only mode. This requires stocking all modified database pages in
   memory and then writing them to disk through file operations.
   
   - Warning:
   On the other hand, [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap]) adds the possibility for stray
   application writes thru pointers to silently corrupt the database.
   
   - Note:
   The [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap]) mode is incompatible with nested transactions,
   since this is unreasonable. I.e. nested transactions requires mallocation
   of database pages and more work for tracking ones, which neuters a
   performance boost caused by the [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap]) mode.
   
   This flag affects only at environment opening but can't be changed after.
   - Tag: MDBXEnvironmentFlags.writeMap
   */
  static let writeMap = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_WRITEMAP.rawValue)
  
  /**
   Tie reader locktable slots to read-only transactions
   instead of to threads.
   
   Don't use Thread-Local Storage, instead tie reader locktable slots to
   \ref MDBX_txn objects instead of to threads. So, \ref mdbx_txn_reset()
   keeps the slot reserved for the \ref MDBX_txn object. A thread may use
   parallel read-only transactions. And a read-only transaction may span
   threads if you synchronizes its use.
   
   Applications that multiplex many user threads over individual OS threads
   need this option. Such an application must also serialize the write
   transactions in an OS thread, since MDBX's write locking is unaware of
   the user threads.
   
   - Note:
   Regardless to [noTLS](x-source-tag://[MDBXEnvironmentFlags.noTLS]) flag a write transaction entirely should
   always be used in one thread from start to finish. MDBX checks this in a
   reasonable manner and return the \ref MDBX_THREAD_MISMATCH error in rules
   violation.
   
   This flag affects only at environment opening but can't be changed after.
   - Tag: MDBXEnvironmentFlags.noTLS
   */
  static let noTLS = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_NOTLS.rawValue)
  
  /**
   Don't do readahead.
   
   Turn off readahead. Most operating systems perform readahead on read
   requests by default. This option turns it off if the OS supports it.
   Turning it off may help random read performance when the DB is larger
   than RAM and system RAM is full.
   
   By default libmdbx dynamically enables/disables readahead depending on
   the actual database size and currently available memory. On the other
   hand, such automation has some limitation, i.e. could be performed only
   when DB size changing but can't tracks and reacts changing a free RAM
   availability, since it changes independently and asynchronously.
   
   - Note:
   The mdbx_is_readahead_reasonable() function allows to quickly find
   out whether to use readahead or not based on the size of the data and the
   amount of available memory.
   
   This flag affects only at environment opening and can't be changed after.
   - Tag: MDBXEnvironmentFlags.noReadAhead
   */
  static let noReadAhead = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_NORDAHEAD.rawValue)
  
  /**
   Don't initialize malloc'ed memory before writing to datafile.
   
   Don't initialize malloc'ed memory before writing to unused spaces in the
   data file. By default, memory for pages written to the data file is
   obtained using malloc. While these pages may be reused in subsequent
   transactions, freshly malloc'ed pages will be initialized to zeroes before
   use. This avoids persisting leftover data from other code (that used the
   heap and subsequently freed the memory) into the data file.
   
   Note that many other system libraries may allocate and free memory from
   the heap for arbitrary uses. E.g., stdio may use the heap for file I/O
   buffers. This initialization step has a modest performance cost so some
   applications may want to disable it using this flag. This option can be a
   problem for applications which handle sensitive data like passwords, and
   it makes memory checkers like Valgrind noisy. This flag is not needed
   with [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap]), which writes directly to the mmap instead of using
   malloc for pages. The initialization is also skipped if \ref MDBX_RESERVE
   is used; the caller is expected to overwrite all of the memory that was
   reserved in that case.
   
   This flag may be changed at any time using `mdbx_env_set_flags()`.
   - Tag: MDBXEnvironmentFlags.noMemoryInit
   */
  static let noMemoryInit = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_NOMEMINIT.rawValue)
  
  /**
   Aims to coalesce a Garbage Collection items.
   
   With [coalesce](x-source-tag://[MDBXEnvironmentFlags.coalesce]) flag MDBX will aims to coalesce items while recycling
   a Garbage Collection. Technically, when possible short lists of pages
   will be combined into longer ones, but to fit on one database page. As a
   result, there will be fewer items in Garbage Collection and a page lists
   are longer, which slightly increases the likelihood of returning pages to
   Unallocated space and reducing the database file.
   
   This flag may be changed at any time using mdbx_env_set_flags().
   - Tag: MDBXEnvironmentFlags.coalesce
   */
  static let coalesce = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_COALESCE.rawValue)
  
  /**
   LIFO policy for recycling a Garbage Collection items.
   
   [lifoReclaim](x-source-tag://[MDBXEnvironmentFlags.lifoReclaim]) flag turns on LIFO policy for recycling a Garbage
   Collection items, instead of FIFO by default. On systems with a disk
   write-back cache, this can significantly increase write performance, up
   to several times in a best case scenario.
   
   LIFO recycling policy means that for reuse pages will be taken which became
   unused the lastest (i.e. just now or most recently). Therefore the loop of
   database pages circulation becomes as short as possible. In other words,
   the number of pages, that are overwritten in memory and on disk during a
   series of write transactions, will be as small as possible. Thus creates
   ideal conditions for the efficient operation of the disk write-back cache.
   
   [lifoReclaim](x-source-tag://[MDBXEnvironmentFlags.lifoReclaim]) is compatible with all no-sync flags, but gives NO
   noticeable impact in combination with [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) or
   [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync]). Because MDBX will reused pages only before the
   last "steady" MVCC-snapshot, i.e. the loop length of database pages
   circulation will be mostly defined by frequency of calling
   \ref mdbx_env_sync() rather than LIFO and FIFO difference.
   
   This flag may be changed at any time using mdbx_env_set_flags().
   - Tag: MDBXEnvironmentFlags.lifoReclaim
   */
  static let lifoReclaim = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_LIFORECLAIM.rawValue)
  
  /**
   Debugging option, fill/perturb released pages.
   - Tag: MDBXEnvironmentFlags.pagePerturb
   */
  static let pagePerturb = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_PAGEPERTURB.rawValue)
}


/** SYNC MODES

 - Attention: Using any combination of [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]),
 [noMetaSync](x-source-tag://[MDBXEnvironmentFlags.noMetaSync]) and especially
 [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync]) is always a deal to
 reduce durability for gain write performance. You must know exactly what
 you are doing and what risks you are taking!
 
 - Note:
 for LMDB users: [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) is NOT similar to `LMDB_NOSYNC`,
 but [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync]) is exactly match `LMDB_NOSYNC`. See details
 below.
 
 THE SCENE:
 - The DAT-file contains several MVCC-snapshots of B-tree at same time,
 each of those B-tree has its own root page.
 - Each of meta pages at the beginning of the DAT file contains a
 pointer to the root page of B-tree which is the result of the particular
 transaction, and a number of this transaction.
 - For data durability, MDBX must first write all MVCC-snapshot data
 pages and ensure that are written to the disk, then update a meta page
 with the new transaction number and a pointer to the corresponding new
 root page, and flush any buffers yet again.
 - Thus during commit a I/O buffers should be flushed to the disk twice;
 i.e. fdatasync(), FlushFileBuffers() or similar syscall should be
 called twice for each commit. This is very expensive for performance,
 but guaranteed durability even on unexpected system failure or power
 outage. Of course, provided that the operating system and the
 underlying hardware (e.g. disk) work correctly.
 
 TRADE-OFF:
 By skipping some stages described above, you can significantly benefit in
 speed, while partially or completely losing in the guarantee of data
 durability and/or consistency in the event of system or power failure.
 Moreover, if for any reason disk write order is not preserved, then at
 moment of a system crash, a meta-page with a pointer to the new B-tree may
 be written to disk, while the itself B-tree not yet. In that case, the
 database will be corrupted!
 
 - Reference:
   [syncDurable](x-source-tag://[MDBXEnvironmentFlags.syncDurable]),
   [noMetaSync](x-source-tag://[MDBXEnvironmentFlags.noMetaSync]),
   [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]),
   [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync])
 
 - Tag: MDBXEnvironmentFlagsSyncModes
 */
protocol MDBXEnvironmentFlagsSyncModes {
  static var syncDurable: MDBXEnvironmentFlags { get }
  static var noMetaSync: MDBXEnvironmentFlags { get }
  static var safeNoSync: MDBXEnvironmentFlags { get }
  static var utterlyNoSync: MDBXEnvironmentFlags { get }
}

extension MDBXEnvironmentFlags: MDBXEnvironmentFlagsSyncModes {
  /**
   Default robust and durable sync mode.
   
   Metadata is written and flushed to disk after a data is written and
   flushed, which guarantees the integrity of the database in the event
   of a crash at any time.
   
   - Attention:
   Please do not use other modes until you have studied all the
   details and are sure. Otherwise, you may lose your users' data, as happens
   in [Miranda NG](https://www.miranda-ng.org/) messenger.
   - Tag: MDBXEnvironmentFlags.syncDurable
   */
  static let syncDurable = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_SYNC_DURABLE.rawValue)
  
  /**
   Don't sync the meta-page after commit.
   
   Flush system buffers to disk only once per transaction commit, omit the
   metadata flush. Defer that until the system flushes files to disk,
   or next non-[readOnly](x-source-tag://[MDBXEnvironmentFlags.readOnly]) commit or \ref mdbx_env_sync().
   Depending on the platform and hardware, with [noMetaSync](x-source-tag://[MDBXEnvironmentFlags.noMetaSync]) you may get a doubling
   of write performance.
   
   This trade-off maintains database integrity, but a system crash may
   undo the last committed transaction. I.e. it preserves the ACI
   (atomicity, consistency, isolation) but not D (durability) database
   property.
   
   [noMetaSync](x-source-tag://[MDBXEnvironmentFlags.noMetaSync]) flag may be changed at any time using
   \ref mdbx_env_set_flags() or by passing to \ref mdbx_txn_begin() for
   particular write transaction.
   - Reference:
     [sync modes](x-source-tag://[MDBXEnvironmentFlagsSyncModes])
   - Tag: MDBXEnvironmentFlags.noMetaSync
   */
  static let noMetaSync = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_NOMETASYNC.rawValue)
  
  /**
   Don't sync anything but keep previous steady commits.
   
   Like [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync]) the
   [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) flag disable similarly
   flush system buffers to disk when committing a transaction. But there is a
   huge difference in how are recycled the MVCC snapshots corresponding to
   previous "steady" transactions (see below).
   
   With [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap])
   the [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) instructs MDBX to use
   asynchronous mmap-flushes to disk. Asynchronous mmap-flushes means that
   actually all writes will scheduled and performed by operation system on it
   own manner, i.e. unordered. MDBX itself just notify operating system that
   it would be nice to write data to disk, but no more.
   
   Depending on the platform and hardware, with [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) you may get
   a multiple increase of write performance, even 10 times or more.
   
   In contrast to [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync]) mode,
   with [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) flag
   MDBX will keeps untouched pages within B-tree of the last transaction
   "steady" which was synced to disk completely. This has big implications for
   both data durability and (unfortunately) performance:
   - a system crash can't corrupt the database, but you will lose the last
   transactions; because MDBX will rollback to last steady commit since it
   kept explicitly.
   - the last steady transaction makes an effect similar to "long-lived" read
   transaction (see above in the [Restrictions & Caveats](https://erthink.github.io/libmdbx/intro.html#restrictions) section)
   since prevents reuse of pages freed by newer write transactions, thus the any data
   changes will be placed in newly allocated pages.
   - to avoid rapid database growth, the system will sync data and issue
   a steady commit-point to resume reuse pages, each time there is
   insufficient space and before increasing the size of the file on disk.
   
   In other words, with [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync])
   flag MDBX insures you from the
   whole database corruption, at the cost increasing database size and/or
   number of disk IOPs. So, [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync])
   flag could be used with
   \ref mdbx_env_sync() as alternatively for batch committing or nested
   transaction (in some cases). As well, auto-sync feature exposed by
   \ref mdbx_env_set_syncbytes() and \ref mdbx_env_set_syncperiod() functions
   could be very useful with [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) flag.
   
   The number and volume of of disk IOPs with [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) flag will
   exactly the as without any no-sync flags. However, you should expect a
   larger process's [work set](https://bit.ly/2kA2tFX) and significantly worse
   a [locality of reference](https://bit.ly/2mbYq2J), due to the more
   intensive allocation of previously unused pages and increase the size of
   the database.
   
   [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) flag may be changed at any time using
   \ref mdbx_env_set_flags() or by passing to \ref mdbx_txn_begin() for
   particular write transaction.
   - Tag: MDBXEnvironmentFlags.safeNoSync
   */
  static let safeNoSync = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_SAFE_NOSYNC.rawValue)
  
  /**
   Don't sync anything and wipe previous steady commits.
   
   Don't flush system buffers to disk when committing a transaction. This
   optimization means a system crash can corrupt the database, if buffers are
   not yet flushed to disk. Depending on the platform and hardware, with
   [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync])
   you may get a multiple increase of write performance,
   even 100 times or more.
   
   If the filesystem preserves write order (which is rare and never provided
   unless explicitly noted) and the [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap]) and
   [lifoReclaim](x-source-tag://[MDBXEnvironmentFlags.lifoReclaim]) flags are not used,
   then a system crash can't corrupt the
   database, but you can lose the last transactions, if at least one buffer is
   not yet flushed to disk. The risk is governed by how often the system
   flushes dirty buffers to disk and how often \ref mdbx_env_sync() is called.
   So, transactions exhibit ACI (atomicity, consistency, isolation) properties
   and only lose `D` (durability). I.e. database integrity is maintained, but
   a system crash may undo the final transactions.
   
   Otherwise, if the filesystem not preserves write order (which is
   typically) or [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap]) or
   [lifoReclaim](x-source-tag://[MDBXEnvironmentFlags.lifoReclaim]) flags are used,
   you should expect the corrupted database after a system crash.
   
   So, most important thing about [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync]):
   - a system crash immediately after commit the write transaction
   high likely lead to database corruption.
   - successful completion of mdbx_env_sync(force = true) after one or
   more committed transactions guarantees consistency and durability.
   - BUT by committing two or more transactions you back database into
   a weak state, in which a system crash may lead to database corruption!
   In case single transaction after mdbx_env_sync, you may lose transaction
   itself, but not a whole database.
   
   Nevertheless, [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync])
   provides "weak" durability in case
   of an application crash (but no durability on system failure), and
   therefore may be very useful in scenarios where data durability is
   not required over a system failure (e.g for short-lived data), or if you
   can take such risk.
   
   [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync])
   flag may be changed at any time using
   \ref mdbx_env_set_flags(), but don't has effect if passed to
   \ref mdbx_txn_begin() for particular write transaction.
   - Reference:
     [sync modes](x-source-tag://[MDBXEnvironmentFlagsSyncModes])
   - Tag: MDBXEnvironmentFlags.utterlyNoSync
   */
  static let utterlyNoSync = MDBXEnvironmentFlags(rawValue: libmdbx_ios.MDBX_UTTERLY_NOSYNC.rawValue)
}

internal extension MDBXEnvironmentFlags {
  var MDBX_env_flags_t: MDBX_env_flags_t {
    libmdbx_ios.MDBX_env_flags_t(self.rawValue)
  }
}
