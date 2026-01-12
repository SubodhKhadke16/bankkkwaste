import 'package:flutter/material.dart';

import '../config/theme.dart';

class WastecOrderCard extends StatefulWidget {
  const WastecOrderCard({required this.order, super.key});

  final Map<String, dynamic> order;

  @override
  State<WastecOrderCard> createState() => _WastecOrderCardState();
}

class _WastecOrderCardState extends State<WastecOrderCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final orderColor = order['color']! as Color;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _isExpanded 
                ? orderColor.withOpacity(0.15)
                : Colors.black.withOpacity(0.06),
            blurRadius: _isExpanded ? 20 : 10,
            offset: Offset(0, _isExpanded ? 10 : 4),
          ),
        ],
      ),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isExpanded 
                  ? orderColor.withOpacity(0.5)
                  : orderColor.withOpacity(0.15),
              width: _isExpanded ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                    if (_isExpanded) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                splashColor: orderColor.withOpacity(0.1),
                highlightColor: orderColor.withOpacity(0.05),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // Icon Container
                      Hero(
                        tag: 'order_icon_${order['id']}',
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                orderColor.withOpacity(0.15),
                                orderColor.withOpacity(0.25),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: orderColor.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            order['icon']! as IconData,
                            color: orderColor,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Order Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Order ${order['id']}",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        orderColor.withOpacity(0.15),
                                        orderColor.withOpacity(0.25),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: orderColor.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    order['status']! as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: orderColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: WastecColors.primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: WastecColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  order['eta']! as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: WastecColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Animated Arrow
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: orderColor.withOpacity(_isExpanded ? 0.15 : 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: RotationTransition(
                          turns: _rotationAnimation,
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: orderColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Animated Content
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: _isExpanded
                      ? Column(
                          children: [
                            // Divider
                            Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    orderColor.withOpacity(0.5),
                                    orderColor.withOpacity(0.7),
                                    orderColor.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.update_rounded,
                                        size: 14,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        order['lastUpdate']! as String,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _WastecInfoChip(
                                          icon: Icons.monitor_weight_outlined,
                                          label: order['weight']! as String,
                                          color: orderColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _WastecInfoChip(
                                          icon: Icons.payments_outlined,
                                          label: order['payment']! as String,
                                          color: orderColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _WastecRouteStops(
                                    pickup: order['pickup']! as String,
                                    drop: order['drop']! as String,
                                    notes: order['notes']! as String,
                                    color: orderColor,
                                  ),
                                  const SizedBox(height: 18),
                                  _WastecDriverCard(
                                    name: order['agent']! as String,
                                    vehicle: order['vehicle']! as String,
                                    contact: order['contact']! as String,
                                    color: orderColor,
                                  ),
                                  const SizedBox(height: 18),
                                  WastecDeliveryProgress(
                                    stage: order['stage']! as int,
                                    color: orderColor,
                                  ),
                                  const SizedBox(height: 20),
                                  WastecOrderTimeline(
                                    currentStage: order['stage']! as int,
                                    timeline: order['timeline']! as List<String?>,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WastecOrderTimeline extends StatelessWidget {
  const WastecOrderTimeline({required this.currentStage, required this.timeline, super.key});

  final int currentStage;
  final List<String?> timeline;

  static int get stageCount => _stages.length;

  static _WastecOrderStage stageAt(int index) {
    final safeIndex = index.clamp(0, _stages.length - 1).toInt();
    return _stages[safeIndex];
  }

  static final List<_WastecOrderStage> _stages = [
    const _WastecOrderStage(
      label: 'Picked',
      description: 'Waste partner collected your scrap from the scheduled address.',
      location: 'Pickup Point',
      icon: Icons.person_pin_circle_outlined,
    ),
    const _WastecOrderStage(
      label: 'Shipped',
      description: 'Package is on the move to our processing centre.',
      location: 'Transit Hub',
      icon: Icons.local_shipping_outlined,
    ),
    const _WastecOrderStage(
      label: 'Material Recovery Facility',
      description: 'Material reached the recovery facility for initial screening.',
      location: 'Wastec MRF',
      icon: Icons.factory_outlined,
    ),
    const _WastecOrderStage(
      label: 'Segregated',
      description: 'Scrap is sorted into clean batches for recycling partners.',
      location: 'Sorting Line 3',
      icon: Icons.category_outlined,
    ),
    const _WastecOrderStage(
      label: 'Shipping',
      description: 'Your sorted material is en route to the recycler hub.',
      location: 'Outbound Logistics',
      icon: Icons.directions_boat_outlined,
    ),
    const _WastecOrderStage(
      label: 'Recycler',
      description: 'Recycler has received the material and final processing starts.',
      location: 'Recycler Facility',
      icon: Icons.recycling,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeStage = currentStage < 0
        ? 0
        : currentStage >= _stages.length
            ? _stages.length - 1
            : currentStage;

    final stageTimes = List<String?>.generate(_stages.length, (index) {
      if (index < timeline.length) {
        return timeline[index];
      }
      return null;
    });

    return Column(
      children: List.generate(_stages.length, (index) {
        final stage = _stages[index];
        final isCompleted = index <= activeStage;
        final isCurrent = index == activeStage;
        final hasPassed = index < activeStage;
        final timeLabel = stageTimes[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WastecTimelineNode(
              isFirst: index == 0,
              isLast: index == _stages.length - 1,
              upperActive: isCompleted,
              lowerActive: hasPassed,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  bottom: index == _stages.length - 1 ? 0 : 16,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? WastecColors.primaryGreen.withOpacity(isCurrent ? 0.16 : 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: WastecColors.primaryGreen.withOpacity(isCompleted ? 0.5 : 0.18),
                  ),
                  boxShadow: [
                    if (isCompleted)
                      BoxShadow(
                        color: WastecColors.primaryGreen.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(stage.icon, size: 18, color: WastecColors.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stage.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color:
                                  isCompleted ? Colors.black87 : Colors.black87.withOpacity(0.75),
                            ),
                          ),
                        ),
                        if (timeLabel != null)
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (stage.location != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.black45),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                stage.location!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      stage.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.black87.withOpacity(isCompleted ? 0.9 : 0.7),
                      ),
                    ),
                    if (isCurrent && !hasPassed) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: WastecColors.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'On the way to the next stop',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: WastecColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _WastecOrderStage {
  const _WastecOrderStage({
    required this.label,
    required this.description,
    required this.icon, this.location,
  });

  final String label;
  final String description;
  final String? location;
  final IconData icon;
}

class WastecTimelineNode extends StatelessWidget {
  const WastecTimelineNode({
    required this.isFirst, required this.isLast, required this.upperActive, required this.lowerActive, required this.isCompleted, required this.isCurrent, super.key,
  });

  final bool isFirst;
  final bool isLast;
  final bool upperActive;
  final bool lowerActive;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    const double lineWidth = 2;
    const activeColor = WastecColors.primaryGreen;
    final inactiveColor = activeColor.withOpacity(0.2);

    final dotFill = isCompleted ? activeColor : Colors.white;
    final dotBorder = isCompleted ? activeColor : activeColor.withOpacity(0.5);

    return SizedBox(
      width: 28,
      child: Column(
        children: [
          if (!isFirst)
            Container(
              width: lineWidth,
              height: 18,
              color: upperActive ? activeColor : inactiveColor,
            ),
          Container(
            width: isCurrent ? 20 : 18,
            height: isCurrent ? 20 : 18,
            decoration: BoxDecoration(
              color: dotFill,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? activeColor : dotBorder,
                width: isCurrent ? 3 : 2,
              ),
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 10,
                    color: Colors.white,
                  )
                : null,
          ),
          if (!isLast)
            Container(
              width: lineWidth,
              height: 26,
              color: lowerActive ? activeColor : inactiveColor,
            ),
        ],
      ),
    );
  }
}

class _WastecInfoChip extends StatelessWidget {
  const _WastecInfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.25),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
}

class _WastecRouteStops extends StatelessWidget {
  const _WastecRouteStops({
    required this.pickup,
    required this.drop,
    required this.notes,
    required this.color,
  });

  final String pickup;
  final String drop;
  final String notes;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WastecRoutePoint(
              title: 'Pickup',
              detail: pickup,
              icon: Icons.store_mall_directory_outlined,
              accent: color,
            ),
            _WastecRouteDivider(color: color),
            _WastecRoutePoint(
              title: 'Drop-off',
              detail: drop,
              icon: Icons.location_city_outlined,
              accent: Colors.deepOrangeAccent,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _WastecRoutePoint extends StatelessWidget {
  const _WastecRoutePoint({
    required this.title,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String detail;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _WastecRouteDivider extends StatelessWidget {
  const _WastecRouteDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 17),
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withOpacity(0.5),
                    color.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 26),
            Expanded(
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      color.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _WastecDriverCard extends StatelessWidget {
  const _WastecDriverCard({
    required this.name,
    required this.vehicle,
    required this.contact,
    required this.color,
  });

  final String name;
  final String vehicle;
  final String contact;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.delivery_dining, color: color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 4,
                      shadowColor: color.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class WastecDeliveryProgress extends StatelessWidget {
  const WastecDeliveryProgress({required this.stage, required this.color, super.key});

  final int stage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safeStage = stage.clamp(0, WastecOrderTimeline.stageCount - 1);
    final completedSteps = safeStage + 1;
    final progress = completedSteps / WastecOrderTimeline.stageCount;
    final currentStage = WastecOrderTimeline.stageAt(safeStage).label;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Journey Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedSteps of ${WastecOrderTimeline.stageCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Current: $currentStage',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
