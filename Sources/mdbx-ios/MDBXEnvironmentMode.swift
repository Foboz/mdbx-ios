//
//  MDBXEnvironmentMode.swift
//  mdbx-ios
//
//  Created by Mikhail Nikanorov on 4/13/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation

/**
 * [LMDB documentation](http://www.lmdb.tech/doc/lmdb_8h.html#a6bc5fbe1ea1873df138108acdf04a28d), [GNU documentation](https://www.gnu.org/software/libc/manual/html_node/Permission-Bits.html)
 *
 * For a directory it gives permission to delete a file in that directory only if you own that file. Ordinarily, a user can either delete all the files in a directory or cannot delete any of them (based on whether the user has write permission for the directory). The same restriction applies—you must have both write permission for the directory and own the file you want to delete. The one exception is that the owner of the directory can delete any file in the directory, no matter who owns it (provided the owner has given himself write permission for the directory). This is commonly used for the `/tmp` directory, where anyone may create files but not delete files created by other users.
 * Originally the sticky bit on an executable file modified the swapping policies of the system. Normally, when a program terminated, its pages in core were immediately freed and reused. If the sticky bit was set on the executable file, the system kept the pages in core for a while as if the program were still running. This was advantageous for a program likely to be run many times in succession. This usage is obsolete in modern systems. When a program terminates, its pages always remain in core as long as there is no shortage of memory in the system. When the program is next run, its pages will still be in core if no shortage arose since the last run.
 * On some modern systems where the sticky bit has no useful meaning for an executable file, you cannot set the bit at all for a non-directory. If you try, `chmod` fails with `EFTYPE`; see [Setting Permissions](https://www.gnu.org/software/libc/manual/html_node/Setting-Permissions.html).
 * Some systems (particularly SunOS) have yet another use for the sticky bit. If the sticky bit is set on a file that is not executable, it means the opposite: never cache the pages of this file at all. The main use of this is for the files on an NFS server machine which are used as the swap area of diskless client machines. The idea is that the pages of the file will be cached in the client’s memory, so it is a waste of the server’s memory to cache them a second time. With this usage the sticky bit also implies that the filesystem may fail to record the file’s modification time onto disk reliably (the idea being that no-one cares for a swap file).
 * This bit is only available on BSD systems (and those derived from them). Therefore one has to use the `_GNU_SOURCE` feature select macro, or not define any feature test macros, to get the definition (see [Feature Test Macros](https://www.gnu.org/software/libc/manual/html_node/Feature-Test-Macros.html)).
 * The actual bit values of the symbols are listed in the table above so you can decode file mode values when debugging your programs. These bit values are correct for most systems, but they are not guaranteed.
 *
 * **Warning**: Writing explicit numbers for file permissions is bad practice. Not only is it not portable, it also requires everyone who reads your program to remember what the bits mean. To make your program clean use the symbolic names.
 *
 * - Tag: EnvironmentMode
 */
public struct MDBXEnvironmentMode: OptionSet {
  public typealias RawValue = UInt16
  public var rawValue: UInt16
  
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  /**
   * Read permission bit for the owner of the file. On many systems this bit is 0400.
   *
   * - Tag: EnvironmentMode.readPermissionBit
   */
  public static let readPermissionBit = MDBXEnvironmentMode(rawValue: S_IRUSR)
  /**
   * Write permission bit for the owner of the file. Usually 0200.
   *
   * - Tag: EnvironmentMode.writePermissionBit
   */
  public static let writePermissionBit = MDBXEnvironmentMode(rawValue: S_IWUSR)
  /**
   * Execute (for ordinary files) or search (for directories) permission bit for the owner of the file. Usually 0100.
   *
   * - Tag: EnvironmentMode.executeOrSearchPermissionBit
   */
  public static let executeOrSearchPermissionBit = MDBXEnvironmentMode(rawValue: S_IXUSR)
  /**
   * This is equivalent to
   * [[.readPermissionBit](x-source-tag://[EnvironmentMode.readPermissionBit]),
   * [.writePermissionBit](x-source-tag://[EnvironmentMode.writePermissionBit]),
   * [.executeOrSearchPermissionBit](x-source-tag://[EnvironmentMode.executeOrSearchPermissionBit])].
   */
  public static let readWriteExecutePermission: MDBXEnvironmentMode = [.readPermissionBit, .writePermissionBit, .executeOrSearchPermissionBit]
  /**
   * Read permission bit for the group owner of the file. Usually 040.
   *
   * - Tag: EnvironmentMode.readPermissionGroupBit
   */
  public static let readPermissionGroupBit = MDBXEnvironmentMode(rawValue: S_IRGRP)
  /**
   * Write permission bit for the group owner of the file. Usually 020.
   *
   * - Tag: EnvironmentMode.writePermissionGroupBit
   */
  public static let writePermissionGroupBit = MDBXEnvironmentMode(rawValue: S_IWGRP)
  /**
   * Execute or search permission bit for the group owner of the file. Usually 010.
   *
   * - Tag: EnvironmentMode.executeOrSearchPermissionGroupBit
   */
  public static let executeOrSearchPermissionGroupBit = MDBXEnvironmentMode(rawValue: S_IXGRP)
  /**
   * This is equivalent to
   * [[.readPermissionGroupBit](x-source-tag://[EnvironmentMode.readPermissionGroupBit]),
   * [.writePermissionGroupBit](x-source-tag://[EnvironmentMode.writePermissionGroupBit]),
   * [.executeOrSearchPermissionGroupBit](x-source-tag://[EnvironmentMode.executeOrSearchPermissionGroupBit])].
   */
  public static let readWriteExecutePermissionGroup: MDBXEnvironmentMode = [.readPermissionGroupBit, .writePermissionGroupBit, .executeOrSearchPermissionGroupBit]
  /**
   * Read permission bit for other users. Usually 04.
   *
   * - Tag: EnvironmentMode.readPermissionOtherBit
   */
  public static let readPermissionOtherBit = MDBXEnvironmentMode(rawValue: S_IROTH)
  /**
   * Write permission bit for other users. Usually 02.
   *
   * - Tag: EnvironmentMode.writePermissionOtherBit
   */
  public static let writePermissionOtherBit = MDBXEnvironmentMode(rawValue: S_IWOTH)
  /**
   * Execute or search permission bit for other users. Usually 01.
   *
   * - Tag: EnvironmentMode.executeOrSearchOtherBit
   */
  public static let executeOrSearchPermissionOtherBit = MDBXEnvironmentMode(rawValue: S_IXOTH)
  /**
   * This is equivalent to
   * [[.readPermissionOtherBit](x-source-tag://[EnvironmentMode.readPermissionOtherBit]),
   * [.writePermissionOtherBit](x-source-tag://[EnvironmentMode.writePermissionOtherBit]),
   * [.executeOrSearchOtherBit](x-source-tag://[EnvironmentMode.executeOrSearchOtherBit])].
   */
  public static let readWriteExecutePermissionOther: MDBXEnvironmentMode = [.readPermissionOtherBit, .writePermissionOtherBit, .executeOrSearchPermissionOtherBit]
  /**
   * This is equivalent to
   * [[.readPermissionBit](x-source-tag://[EnvironmentMode.readPermissionBit]),
   * [.writePermissionBit](x-source-tag://[EnvironmentMode.writePermissionBit]),
   * [.readPermissionGroupBit](x-source-tag://[EnvironmentMode.readPermissionGroupBit]),
   * [.writePermissionGroupBit](x-source-tag://[EnvironmentMode.writePermissionGroupBit]),
   * [.readPermissionOtherBit](x-source-tag://[EnvironmentMode.readPermissionOtherBit])].
   */
  public static let iOSPermission: MDBXEnvironmentMode = [.readPermissionBit, .writePermissionBit, .readPermissionGroupBit, .writePermissionGroupBit, .readPermissionOtherBit]
  /**
   * This is equivalent to
   * [[.readPermissionBit](x-source-tag://[EnvironmentMode.readPermissionBit]),
   * [.readPermissionGroupBit](x-source-tag://[EnvironmentMode.readPermissionGroupBit]),
   * [.readPermissionOtherBit](x-source-tag://[EnvironmentMode.readPermissionOtherBit])].
   */
  public static let readOnlyPermission: MDBXEnvironmentMode = [.readPermissionBit, .readPermissionGroupBit, .readPermissionOtherBit]
}
