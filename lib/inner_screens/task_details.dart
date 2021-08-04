import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:workos_arabic/constants/constants.dart';
import 'package:workos_arabic/services/global_method.dart';
import 'package:workos_arabic/widgets/comments_widget.dart';

class TaskDetails extends StatefulWidget {
  final String taskId;
  final String uploadedBy;

  const TaskDetails({required this.taskId, required this.uploadedBy});
  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  bool _isCommenting = false;
  var contentsInfo = TextStyle(
      fontWeight: FontWeight.normal, fontSize: 15, color: Constants.darkBlue);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _authorName;
  String? _authorPosition;
  String? taskDescription;
  String? taskTitle;
  bool? _isDone;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? deadlineDate;
  String? postedDate;
  String? userImageUrl;
  bool isDeadlineAvailable = false;
  bool _isLoading = false;
  TextEditingController _commentController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uploadedBy)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          _authorName = userDoc.get('name');
          _authorPosition = userDoc.get('positionInCompany');
          userImageUrl = userDoc.get('userImageUrl');
        });
      }
      final DocumentSnapshot taskDatabase = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();
      if (taskDatabase == null) {
        return;
      } else {
        setState(() {
          taskDescription = taskDatabase.get('taskDescription');
          _isDone = taskDatabase.get('isDone');
          deadlineDate = taskDatabase.get('deadlineDate');
          deadlineDateTimeStamp = taskDatabase.get('deadlineDateTimeStamp');
          postedDateTimeStamp = taskDatabase.get('createdAt');
          var postDate = postedDateTimeStamp!.toDate();
          postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
          var date = deadlineDateTimeStamp!.toDate();
          isDeadlineAvailable = date.isAfter(DateTime.now());
        });
      }
    } catch (error) {
      GlobalMethods.showErrorDialog(
          error: 'An error occured', context: context);
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Back',
            style: TextStyle(
                color: Constants.darkBlue,
                fontStyle: FontStyle.italic,
                fontSize: 20),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Text(
                'Fetching data',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      taskTitle == null ? '' : taskTitle!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Constants.darkBlue),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'uploaded by',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Constants.darkBlue),
                                ),
                                Spacer(),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 3,
                                      color: Colors.pink.shade800,
                                    ),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          userImageUrl == null
                                              ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                                              : userImageUrl!,
                                        ),
                                        fit: BoxFit.fill),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _authorName == null ? '' : _authorName!,
                                      style: contentsInfo,
                                    ),
                                    Text(
                                      _authorPosition == null
                                          ? ''
                                          : _authorPosition!,
                                      style: contentsInfo,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Uploaded on:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Constants.darkBlue),
                                ),
                                Text(
                                  postedDate == null ? '' : postedDate!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: Constants.darkBlue),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Deadline date:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Constants.darkBlue),
                                ),
                                Text(
                                  deadlineDate == null ? '' : deadlineDate!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                isDeadlineAvailable
                                    ? 'Still have enough time'
                                    : "No time left",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
                                    color: isDeadlineAvailable
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Done state:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Constants.darkBlue),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Flexible(
                                    child: TextButton(
                                  child: Text('Done',
                                      style: TextStyle(
                                          decoration: _isDone == true
                                              ? TextDecoration.underline
                                              : TextDecoration.none,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 15,
                                          color: Constants.darkBlue)),
                                  onPressed: () {
                                    User? user = _auth.currentUser;
                                    String _uid = user!.uid;
                                    if (_uid == widget.uploadedBy) {
                                      FirebaseFirestore.instance
                                          .collection('tasks')
                                          .doc(widget.taskId)
                                          .update({'isDone': true});
                                      getData();
                                    } else {
                                      GlobalMethods.showErrorDialog(
                                          error:
                                              'You can\'t perform this action',
                                          context: context);
                                    }
                                  },
                                )),
                                Opacity(
                                  opacity: _isDone == true ? 1 : 0,
                                  child: Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                ),
                                Flexible(
                                    child: TextButton(
                                  child: Text('Not done',
                                      style: TextStyle(
                                        decoration: _isDone == false
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        color: Constants.darkBlue,
                                      )),
                                  onPressed: () {
                                    User? user = _auth.currentUser;
                                    String _uid = user!.uid;
                                    if (_uid == widget.uploadedBy) {
                                      FirebaseFirestore.instance
                                          .collection('tasks')
                                          .doc(widget.taskId)
                                          .update({'isDone': false});
                                      getData();
                                    } else {
                                      GlobalMethods.showErrorDialog(
                                          error:
                                              'You can\'t perform this action',
                                          context: context);
                                    }
                                  },
                                )),
                                Opacity(
                                  opacity: _isDone == false ? 1 : 0,
                                  child: Icon(
                                    Icons.check_box,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Task description:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Constants.darkBlue),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              taskDescription == null ? '' : taskDescription!,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: Constants.darkBlue,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                              child: _isCommenting
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: TextField(
                                            maxLength: 200,
                                            controller: _commentController,
                                            style: TextStyle(
                                              color: Constants.darkBlue,
                                            ),
                                            keyboardType: TextInputType.text,
                                            maxLines: 6,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.red),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.pink),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  MaterialButton(
                                                    onPressed: () async {
                                                      if (_commentController
                                                              .text.length <
                                                          7) {
                                                        GlobalMethods
                                                            .showErrorDialog(
                                                                error:
                                                                    'Comment cant be less than 7 characteres',
                                                                context:
                                                                    context);
                                                      } else {
                                                        final _generatedId =
                                                            Uuid().v4();
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('tasks')
                                                            .doc(widget.taskId)
                                                            .update({
                                                          'taskComments':
                                                              FieldValue
                                                                  .arrayUnion([
                                                            {
                                                              'userId': widget
                                                                  .uploadedBy,
                                                              'commentId':
                                                                  _generatedId,
                                                              'name':
                                                                  _authorName,
                                                              'commentBody':
                                                                  _commentController
                                                                      .text,
                                                              'time': Timestamp
                                                                  .now(),
                                                              'userImageUrl':
                                                                  userImageUrl,
                                                            }
                                                          ]),
                                                        });
                                                        await Fluttertoast.showToast(
                                                            msg:
                                                                "Task has been uploaded successfuly",
                                                            toastLength: Toast
                                                                .LENGTH_LONG,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            fontSize: 16.0);
                                                        _commentController
                                                            .clear();
                                                        setState(() {});
                                                      }
                                                    },
                                                    color: Colors.pink.shade700,
                                                    elevation: 10,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        13),
                                                            side: BorderSide
                                                                .none),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 14),
                                                      child: Text(
                                                        'Post',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            // fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _isCommenting =
                                                              !_isCommenting;
                                                        });
                                                      },
                                                      child: Text('Cancel')),
                                                ],
                                              ),
                                            ))
                                      ],
                                    )
                                  : Center(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _isCommenting = !_isCommenting;
                                          });
                                        },
                                        color: Colors.pink.shade700,
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            side: BorderSide.none),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          child: Text(
                                            'Add a comment',
                                            style: TextStyle(
                                                color: Colors.white,
                                                // fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('tasks')
                                    .doc(widget.taskId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    if (snapshot.data == null) {
                                      return Container();
                                    }
                                  }
                                  return ListView.separated(
                                      reverse: true,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (ctx, index) {
                                        return CommentWidget(
                                          commentId:
                                              snapshot.data!['taskComments']
                                                  [index]['commentId'],
                                          commentBody:
                                              snapshot.data!['taskComments']
                                                  [index]['commentBody'],
                                          commenterId:
                                              snapshot.data!['taskComments']
                                                  [index]['userId'],
                                          commenterName:
                                              snapshot.data!['taskComments']
                                                  [index]['name'],
                                          commenterImageUrl:
                                              snapshot.data!['taskComments']
                                                  [index]['userImageUrl'],
                                        );
                                      },
                                      separatorBuilder: (ctx, index) {
                                        return Divider(
                                          thickness: 1,
                                        );
                                      },
                                      itemCount: snapshot
                                          .data!['taskComments'].length);
                                })
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
