package com.swfwire.decompiler
{
	import com.swfwire.decompiler.abc.ABCWriteResult;
	import com.swfwire.decompiler.abc.ABCWriter;
	import com.swfwire.decompiler.data.swf.records.SymbolClassRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf9.tags.DefineBinaryDataTag;
	import com.swfwire.decompiler.data.swf9.tags.DefineFontNameTag;
	import com.swfwire.decompiler.data.swf9.tags.DoABCTag;
	import com.swfwire.decompiler.data.swf9.tags.StartSound2Tag;
	import com.swfwire.decompiler.data.swf9.tags.SymbolClassTag;
	
	import flash.utils.ByteArray;

	public class SWF9Writer extends SWF8Writer
	{
		public static const TAG_IDS:Object = {
			76: SymbolClassTag,
			82: DoABCTag,
			87: DefineBinaryDataTag,
			88: DefineFontNameTag,
			89: StartSound2Tag
		};
		
		private static var FILE_VERSION:uint = 9;
		
		public function SWF9Writer()
		{
			version = FILE_VERSION;
			registerTags(TAG_IDS);
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case DoABCTag:
					writeDoABCTag(context, DoABCTag(tag));
					break;
				case SymbolClassTag:
					writeSymbolClassTag(context, SymbolClassTag(tag));
					break;
				case DefineFontNameTag:
					writeDefineFontNameTag(context, DefineFontNameTag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writeSymbolClassTag(context:SWFWriterContext, tag:SymbolClassTag):void
		{
			var numSymbols:uint = tag.symbols.length;
			context.bytes.writeUI16(numSymbols);
			for(var iter:uint = 0; iter < numSymbols; iter++)
			{
				writeSymbolClassRecord(context, tag.symbols[iter]);
			}
		}
		
		protected function writeDoABCTag(context:SWFWriterContext, tag:DoABCTag):void
		{
			context.bytes.writeUI32(tag.flags);
			context.bytes.writeString(tag.name);
			
			var abcWriter:ABCWriter = new ABCWriter();
			var writeResult:ABCWriteResult = abcWriter.write(tag.abcFile);
			
			if(context.result.abcMetadata.length <= context.tagId)
			{
				context.result.abcMetadata.length = context.tagId + 1;
			}
			context.result.abcMetadata[context.tagId] = writeResult.metadata;
			
			context.bytes.writeBytes(writeResult.bytes);
		}
		
		protected function writeSymbolClassRecord(context:SWFWriterContext, record:SymbolClassRecord):void
		{
			context.bytes.writeUI16(record.characterId);
			context.bytes.writeString(record.className);
		}
		
		protected function writeDefineFontNameTag(context:SWFWriterContext, tag:DefineFontNameTag):void
		{
			context.bytes.writeUI16(tag.fontId);
			context.bytes.writeString(tag.fontName);
			context.bytes.writeString(tag.fontCopyright);
		}
	}
}