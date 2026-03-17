// Archipelago bridge - do not move where this is
class APMemory
{
    int Magic;
    int Version;
	int Signature1;
	int Signature2;
	
	// Whether we're ready for AP to send data
	// After we process it, we will change this status to ready
	int IncomingStatus;
	int IncomingMessageType;
	int IncomingMessageData;
	int IncomingLastProcessedItemIdx; // Serialize the current value in the save data on save
	
	// Whether we're waiting for AP to read data
	// After they process it, they will change this status to ready
	int OutgoingStatus;
	int OutgoingMessageType;
	int OutgoingMessageData;
	int OutgoingLastProcessedItemIdx;
	
	// Goal reached - AP will think it is done if this is set to anything above 0
	int IsGoalReached;
}

APMemory g_AP;

void PrintAPMemory()
{
	Sys.Print("Magic: " + g_AP.Magic);
	Sys.Print("Version: " + g_AP.Version);
	Sys.Print("Signature1: " + g_AP.Signature1);
	Sys.Print("Signature2: " + g_AP.Signature2);
	
	Sys.Print("IncomingStatus: " + g_AP.IncomingStatus);
	Sys.Print("IncomingMessageType: " + g_AP.IncomingMessageType);
	Sys.Print("IncomingMessageData: " + g_AP.IncomingMessageData);
	Sys.Print("IncomingLastProcessedItemIdx: " + g_AP.IncomingLastProcessedItemIdx);
	
	Sys.Print("OutgoingStatus: " + g_AP.OutgoingStatus);
	Sys.Print("OutgoingMessageType: " + g_AP.OutgoingMessageType);
	Sys.Print("OutgoingMessageData: " + g_AP.OutgoingMessageData);
	Sys.Print("OutgoingLastProcessedItemIdx: " + g_AP.OutgoingLastProcessedItemIdx);
	
	Sys.Print("IsGoalReached: " + g_AP.IsGoalReached);
}

class APOutgoingMessage
{
	APMessageType type;
	int data;
	
	APOutgoingMessage() {}
	APOutgoingMessage(const APMessageType &in t, const int &in d)
	{
		type = t;
		data = d;
	}
}
// A global for all outgoing messages - this is here in case we cannot send out
// a check in time for the next one to come in
// The player will check whether we're good to send out the next one every tick
// We will also fill this with EVERY checked location when the game loads, to resync
array<APOutgoingMessage> g_outgoingMessageQueue;

enum APStatus
{
	// Incoming Message: We are ready for AP to send us data
	// Outgoing Message: We can set data for Archipelago to read
	AP_READY = 0,
	
	// Incoming Message: We are NOT ready for AP to send us data (we are processing the last one)
	// Outgoing Message: We CANNOT set data for Archipelago to read (we are waiting for AP to process the last one)
	AP_PROCESSING
}

enum APMessageType
{
	// Default, should be ignored on both ends
	AP_MSGTYPE_NONE = 0,
	
	// Incoming message types
	AP_IN_LAST_PROCESSED_ITEM_IDX,
    AP_IN_MSGTYPE_GET_PICKUP,
    AP_IN_MSGTYPE_GET_WEAPON,
    AP_IN_MSGTYPE_GET_MISSION_ITEM,
    AP_IN_MSGTYPE_GET_AMMO,
    AP_IN_MSGTYPE_GET_TRAP,
	
	// Outgoing message types
	AP_OUT_MSGTYPE_SEND_CHECK
}

void InitAP()
{
	g_AP.Magic = 0x4150524B; // APRK
    g_AP.Version = 1;
	g_AP.Signature1 = 0x43110DAD;
	g_AP.Signature2 = 0x1337BEEF;

    g_AP.IncomingStatus = AP_PROCESSING; // We don't want to process on the title screen
    g_AP.IncomingMessageType = AP_MSGTYPE_NONE;
    g_AP.IncomingMessageData = 0;
	g_AP.IncomingLastProcessedItemIdx = 0;

    g_AP.OutgoingStatus = AP_READY;
    g_AP.OutgoingMessageType = AP_MSGTYPE_NONE;
    g_AP.OutgoingMessageData = 0;
	g_AP.OutgoingLastProcessedItemIdx = 0;
	
	g_AP.IsGoalReached = 0;
}

void ResetAPForLoadData(int& in outgoingLastProcessedItemIdx)
{
	Sys.Print("Resetting last index to: " + outgoingLastProcessedItemIdx);

	// Set this first so AP doesn't try to send us items while we set these
	g_AP.IncomingStatus = AP_PROCESSING;
	g_AP.OutgoingStatus = AP_READY;
	
    g_AP.IncomingMessageType = AP_MSGTYPE_NONE;
    g_AP.IncomingMessageData = 0;
	g_AP.IncomingLastProcessedItemIdx = 0;

    g_AP.OutgoingMessageType = AP_MSGTYPE_NONE;
    g_AP.OutgoingMessageData = 0;
	g_AP.OutgoingLastProcessedItemIdx = outgoingLastProcessedItemIdx;
	
	// Now we're ready to receive
	g_AP.IncomingStatus = AP_READY;
}