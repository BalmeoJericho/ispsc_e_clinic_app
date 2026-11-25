
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebActivityLogs extends StatefulWidget {
  const WebActivityLogs({super.key});

  @override
  State<WebActivityLogs> createState() => _WebActivityLogsState();
}

class _WebActivityLogsState extends State<WebActivityLogs> {

  String searchQuery = "";
  int currentPage = 1;
  final int rowsPerPage = 20;

  String sortColumn = "timestamp";
  bool ascending = false;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFFF4F6FA),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Activity Log",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

////////////////////////////////////////////////////////////
/// SEARCH BAR
////////////////////////////////////////////////////////////

          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search activity...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                  currentPage = 1;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          Expanded(child: _buildLogs()),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////
/// LOGS STREAM
////////////////////////////////////////////////////////////

  Widget _buildLogs() {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("activity_logs")
          .orderBy("timestamp", descending: true)
          .snapshots(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data!.docs;

////////////////////////////////////////////////////////////
/// SEARCH FILTER
////////////////////////////////////////////////////////////

        final filteredLogs = logs.where((doc) {

          final data = doc.data() as Map<String, dynamic>;

          final action =
              (data["action"] ?? "").toString().toLowerCase();

          final details =
              (data["details"] ?? "").toString().toLowerCase();

          return action.contains(searchQuery) ||
              details.contains(searchQuery);

        }).toList();

////////////////////////////////////////////////////////////
/// SORTING
////////////////////////////////////////////////////////////

        filteredLogs.sort((a, b) {

          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;

          dynamic valueA = dataA[sortColumn];
          dynamic valueB = dataB[sortColumn];

          if (sortColumn == "timestamp") {
            valueA = (dataA["timestamp"] as Timestamp?)?.toDate();
            valueB = (dataB["timestamp"] as Timestamp?)?.toDate();
          }

          int result =
              valueA.toString().compareTo(valueB.toString());

          return ascending ? result : -result;
        });

////////////////////////////////////////////////////////////
/// PAGINATION
////////////////////////////////////////////////////////////

        final totalPages =
            (filteredLogs.length / rowsPerPage).ceil().clamp(1, 999);

        final start = (currentPage - 1) * rowsPerPage;

        final end = (start + rowsPerPage) > filteredLogs.length
            ? filteredLogs.length
            : start + rowsPerPage;

        final pageLogs = filteredLogs.sublist(start, end);

////////////////////////////////////////////////////////////
/// TABLE CARD
////////////////////////////////////////////////////////////

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),

          child: Column(
            children: [

////////////////////////////////////////////////////////////
/// HEADER
////////////////////////////////////////////////////////////

              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: const Color(0xFFF2F4F7),

                child: Row(
                  children: [

                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            sortColumn = "timestamp";
                            ascending = !ascending;
                          });
                        },
                        child: const Text(
                          "Date & Time",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            sortColumn = "action";
                            ascending = !ascending;
                          });
                        },
                        child: const Text(
                          "Activity Type",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 6,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            sortColumn = "details";
                            ascending = !ascending;
                          });
                        },
                        child: const Text(
                          "Changes",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

////////////////////////////////////////////////////////////
/// TABLE ROWS
////////////////////////////////////////////////////////////

              Expanded(
                child: ListView.builder(
                  itemCount: pageLogs.length,

                  itemBuilder: (context, index) {

                    final data =
                        pageLogs[index].data() as Map<String, dynamic>;

                    final time =
                        (data["timestamp"] as Timestamp?)?.toDate();

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),

                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE6E6E6),
                          ),
                        ),
                      ),

                      child: Row(
                        children: [

                          Expanded(
                            flex: 3,
                            child: Text(
                              time != null ? _formatDate(time) : "",
                            ),
                          ),

                          Expanded(
                            flex: 3,
                            child: Text(
                              data["action"] ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),

                          Expanded(
                            flex: 6,
                            child: Text(data["details"] ?? ""),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              _buildPagination(totalPages),
            ],
          ),
        );
      },
    );
  }

////////////////////////////////////////////////////////////
/// PAGINATION
////////////////////////////////////////////////////////////

  Widget _buildPagination(int totalPages) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [

        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              currentPage > 1 ? () => setState(() => currentPage--) : null,
        ),

        Text(
          "Page $currentPage of $totalPages",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),

        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              currentPage < totalPages
                  ? () => setState(() => currentPage++)
                  : null,
        ),
      ],
    );
  }

////////////////////////////////////////////////////////////
/// DATE FORMAT
////////////////////////////////////////////////////////////

  String _formatDate(DateTime time) {

    return "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} "
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

////////////////////////////////////////////////////////////
/// CARD DESIGN
////////////////////////////////////////////////////////////

  BoxDecoration _cardDecoration() {

    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          color: Colors.black.withOpacity(0.05),
        )
      ],
    );
  }
}

